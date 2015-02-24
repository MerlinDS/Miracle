/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 19:31
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.EmptyFrameInfo;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.animations.FrameType;
	import com.merlinds.miracle.format.AbstractReader;
	import com.merlinds.miracle.format.ReaderError;
	import com.merlinds.miracle.format.ReaderStatus;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flash.geom.Rectangle;

	import flash.utils.ByteArray;

	public class MAFReader extends AbstractReader{

		private var _header:MAFHeader;
		private var _animations:Object;
		private var _animation:AnimationHelper;//Current animation helper
		///Helpers, contains data from file before adding this data to animation helper
		private var _polygons:Vector.<String>;
		private var _transforms:Vector.<Transformation>;
		private var _transformsLength:int;
		private var _framesLength:int;
		private var _layersRead:int;
		//

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFReader(signature:String, bytesChunk:int = 8960) {
			this.addReadingMethod(this.readAnimationHeader);
			this.addReadingMethod(this.readLayerHeader);
			this.addReadingMethod(this.readPolygons);
			this.addReadingMethod(this.readTransforms);
			this.addReadingMethod(this.readFrames);
			this.addReadingMethod(this.completeAnimation);
			_transforms = new <Transformation>[];
			_polygons = new <String>[];
			super(signature, bytesChunk);
		}

		override public function read(bytes:ByteArray, ...args):void {
			super.read(bytes, args);
			_animations = args[0];
		}

		override public function dispose():void {
			this.cleanTempData();
			_animations = null;
			_header = null;
			super.dispose();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Read file header and parse it to header object
		 */
		override protected function readFileHeader():void {
			_header = new MAFHeader();
			this.bytes.position = MAFHeaderFormat.MT;
			_header.matrixSize = this.bytes.readShort();
			this.bytes.position = MAFHeaderFormat.CT;
			_header.colorSize = this.bytes.readShort();
			this.bytes.position = MAFHeaderFormat.FT;
			_header.frameSize = this.bytes.readShort();
			this.bytes.position = MAFHeaderFormat.DATE;
			_header.modificationDate = this.bytes.readInt();
			this.bytes.position = MAFHeaderFormat.HEADER_SIZE;
			this.methodEnded();
		}

		/**
		 * Read animation header information from file
		 */
		private function readAnimationHeader():void {
			assert(this.bytes.readByte() == ControlCharacters.DLE, ReaderError.BAD_ANIMATION_HEADER);
			if(this.status != ReaderStatus.ERROR)
			{
				this.cleanTempData();
				//read animation header
				var length:int = this.bytes.readShort();
				var name:String = this.bytes.readMultiByte(length, this.charSet);
				//read bounds of animation
				var bounds:Rectangle = new Rectangle(
					this.bytes.readFloat(),
					this.bytes.readFloat(),
					this.bytes.readFloat(),
					this.bytes.readFloat()
				);
				var totalFrames:int = this.bytes.readShort();
				var numLayers:int = this.bytes.readShort();
				//TODO remove name from animation helper
				_animation = new AnimationHelper(name, totalFrames, numLayers);
				_animation.bounds = bounds;
				//add animation to output
				_animations[name] = _animation;
			}
			this.methodEnded();
		}

		/**
		 * Read layer information form file
		 */
		private function readLayerHeader():void {
			if(_layersRead < _animation.numLayers)
			{
				assert(this.bytes.readByte() == ControlCharacters.GS, ReaderError.BAD_LAYER_HEADER);
				if(this.status != ReaderStatus.ERROR)//Do nothing if error was occurred
				{
					_transformsLength = this.bytes.readShort();
					_framesLength = this.bytes.readShort();
					_layersRead++;//Increase layers read counter
					this.methodEnded();
				}
			}else
			{
				//All layers was read. Try to finish reading
				this.methodEnded(this.completeAnimation);
			}
		}

		/**
		 * Read polygons names from file and save it to temporary list
		 */
		private function readPolygons():void {
			var finishByFlag:Boolean = true;
			var sp:int = this.bytes.position;//start reading position
			/* can be a problem with RS flag founding */
			while(this.bytes.readByte() != ControlCharacters.RS)
			{
				this.bytes.position--;
				var size:int = this.bytes.readShort();//polygon name size
				_polygons.push( this.bytes.readMultiByte(size, this.charSet) );
				/*If bytes counter more than bytesChuck size, that stop reading and */
				if(this.bytes.position - sp >= this.bytesChunk)
				{
					finishByFlag = false;
					break;
				}
			}

			if(finishByFlag)//Go to next method only if flag RS was found
				this.methodEnded();
		}

		/**
		 * Read transformations from file and save it to temporary list
		 */
		private function readTransforms():void
		{
			var finishByFlag:Boolean = true;
			var sp:int = this.bytes.position;//start reading position
			while(_transforms.length < _transformsLength)
			{
				var tm:TransformMatrix = this.readTransformMatrix();
				var color:Color = this.readColor();
				_transforms.push( new Transformation(tm, color) );
				/*If bytes counter more than bytesChuck size, that stop reading and */
				if(this.bytes.position - sp >= this.bytesChunk)
				{
					finishByFlag = false;
					break;
				}
			}

			if(finishByFlag)//Go to next method when all transformation for current layer was read
				this.methodEnded();
		}

		/**
		 * Read frames information from file and save it to animation helper
		 */
		private function readFrames():void {
			var finishByFlag:Boolean = true;
			var sp:int = this.bytes.position;//start reading position
			/* Frames in liner list */
			while( _layersRead * _animation.frames.length < _framesLength)
			{
				var frame:FrameInfo;
				var type:uint = this.bytes.readByte();
				if(type == FrameType.EMPTY)frame = new EmptyFrameInfo();
				else{
					var index:int;
					var t0:Transformation, t1:Transformation;
					index = this.bytes.readShort();
					assert(_polygons.length > index, ReaderError.BAD_POLYGON_INDEX);
					if(status == ReaderStatus.ERROR)return;
					var polygonName:String = _polygons[index];

					index = this.bytes.readShort();
					assert(_transforms.length > index, ReaderError.BAD_TRANSFORM_INDEX);
					if(status == ReaderStatus.ERROR)return;
					t0 = _transforms[index];

					if(type == FrameType.MOTION)//Only motion has second transformation
					{
						assert(_transforms.length > index + 1, ReaderError.BAD_TRANSFORM_INDEX);
						if(status == ReaderStatus.ERROR)return;
						t1 = _transforms[index + 1];
					}

					var t:Number = this.bytes.readFloat();
					frame = new FrameInfo(polygonName, t0, t1, t);
				}
				_animation.frames.push(frame);

				/*If bytes counter more than bytesChuck size, that stop reading and */
				if(this.bytes.position - sp >= this.bytesChunk)
				{
					finishByFlag = false;
					break;
				}
			}

			if(finishByFlag)//Go to next method when all transformation for current layer was read
				this.methodEnded(this.readLayerHeader);
		}

		private function completeAnimation():void {
			var nextMethod:Function;
			if(this.bytes.readByte() != ControlCharacters.EOF)
			{
				this.bytes.position--;
				nextMethod = this.readAnimationHeader;
			}
			this.methodEnded(nextMethod);
		}

		//Tools methods
		/**
		 * @private
		 * Clear temp data fields for next animation
		 */
		[Inline]
		private final function cleanTempData():void {
			_transforms.length = 0;
			_polygons.length = 0;
			_transformsLength = 0;
			_framesLength = 0;
			_layersRead = 0;
		}

		/**
		 * @private
		 * Read transformation matrix from file
		 * @return New transformation matrix
		 */
		[Inline]
		private final function readTransformMatrix():TransformMatrix {
			var matrix:TransformMatrix = new TransformMatrix();
			matrix.offsetX = this.bytes.readFloat();
			matrix.offsetY = this.bytes.readFloat();
			matrix.scaleX = this.bytes.readFloat();
			matrix.scaleY = this.bytes.readFloat();
			matrix.skewX = this.bytes.readFloat();
			matrix.skewY = this.bytes.readFloat();
			matrix.tx = this.bytes.readFloat();
			matrix.ty = this.bytes.readFloat();
			return matrix;
		}

		/**
		 * @private
		 * Read colors transformations from file
		 * @return
		 */
		[Inline]
		private final function readColor():Color {
			var color:Color = new Color();
			color.type = this.bytes.readByte();
			this.bytes.position++;
			color.alphaOffset = this.bytes.readShort() / 255;
			color.alphaMultiplier = this.bytes.readShort() / 255;
			color.redOffset = this.bytes.readShort() / 255;
			color.redMultiplier = this.bytes.readShort() / 255;
			color.greenOffset = this.bytes.readShort() / 255;
			color.greenMultiplier = this.bytes.readShort() / 255;
			color.blueOffset = this.bytes.readShort() / 255;
			color.blueMultiplier = this.bytes.readShort() / 255;
			return color;
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}