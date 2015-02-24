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
		private var _polygonsLength:int;
		private var _transformsLength:int;

		//

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFReader(signature:String, bytesChunk:int = 8960) {
			this.addReadingMethod(this.readAnimationHeader);
			this.addReadingMethod(this.readPolygons);
			this.addReadingMethod(this.readTransformations);
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
				//read animation header
				var length:int = this.bytes.readShort();
				var name:String = this.bytes.readMultiByte(length, this.charSet);
				//read bounds of animation
				var bounds:Rectangle = this.readBounds();
				var numLayers:int = this.bytes.readShort();
				var totalFrames:int = this.bytes.readShort();
				_transformsLength = this.bytes.readShort();
				_polygonsLength = this.bytes.readShort();
				//TODO remove name from animation helper
				_animation = new AnimationHelper(name, totalFrames, numLayers);
				_animation.bounds = bounds;
				//add animation to output
				_animations[name] = _animation;
			}
			this.methodEnded();
		}

		/**
		 * Read polygons names in temporary list
		 */
		private function readPolygons():void {
			var finishByFlag:Boolean = true;
			var sp:int = this.bytes.position;//start reading position
			while(_polygons.length < _polygonsLength)
			{
				var size:int = this.bytes.readShort();
				_polygons.push( this.bytes.readMultiByte(size, this.charSet) );
				if(this.bytes.position - sp >= this.bytesChunk)
				{
					finishByFlag = false;
					break;
				}
			}

			if(finishByFlag)//Go to next method only if reading was ended
				this.methodEnded();
		}

		/**
		 * Read transformations in temporary list
		 */
		private function readTransformations():void {
			var finishByFlag:Boolean = true;
			var sp:int = this.bytes.position;//start reading position
			while(_transforms.length < _transformsLength)
			{
				var t:Transformation = new Transformation(
					this.readTransformMatrix(),
					this.readColor()
				);
				_transforms.push(t);
				if(this.bytes.position - sp >= this.bytesChunk)
				{
					finishByFlag = false;
					break;
				}
			}

			if(finishByFlag)//Go to next method only if reading was ended
				this.methodEnded();
		}

		/**
		 * Read frames to animation
		 */
		private function readFrames():void {
			var finishByFlag:Boolean = true;
			var sp:int = this.bytes.position;//start reading position
			while(_animation.frames.length < _animation.totalFrames * _animation.numLayers)
			{
				var frame:FrameInfo;
				var type:uint = this.bytes.readByte();
				if(type == FrameType.EMPTY)frame = new EmptyFrameInfo();
				else
				{
					var index:int = this.bytes.readShort();
					//TODO add validation
					var polygonName:String = _polygons[index];
					index = this.bytes.readShort();
					var m0:Transformation, m1:Transformation;
					m0 = _transforms[index];
					index = this.bytes.readShort();
					if(index >= 0)m1 = _transforms[index];
					var t:Number = this.bytes.readFloat();
					frame = new FrameInfo(polygonName, m0, m1, t);
				}
				_animation.frames.push(frame);
				//breaker
				if(this.bytes.position - sp >= this.bytesChunk)
				{
					finishByFlag = false;
					break;
				}
			}

			if(finishByFlag)//Go to next method only if reading was ended
				this.methodEnded();
		}

		/**
		 * End reading or read next animation
		 */
		private function completeAnimation():void {
			var nextMethod:Function;
			if(this.bytes.readByte() != ControlCharacters.EOF)
			{
				this.bytes.position--;
				nextMethod = this.readAnimationHeader;
			}
			this.cleanTempData();
			this.methodEnded(nextMethod);
		}

		//Tools methods
		/**
		 * @private
		 * Clear temp data fields for next animation
		 */
		[Inline]
		private final function cleanTempData():void {
			_transformsLength = 0;
			_polygonsLength = 0;
			_transforms.length = 0;
			_polygons.length = 0;
		}

		/**
		 * @private
		 * Read bounds from file
		 * @return Bounds rect
		 */
		private function readBounds():Rectangle {
			return new Rectangle(
					this.bytes.readFloat(),
					this.bytes.readFloat(),
					this.bytes.readFloat(),
					this.bytes.readFloat()
			);
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