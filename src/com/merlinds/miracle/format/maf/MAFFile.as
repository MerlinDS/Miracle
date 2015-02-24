/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 18:46
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.animations.FrameType;
	import com.merlinds.miracle.format.FormatFile;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;

	public class MAFFile extends FormatFile {

		private var _header:MAFHeader;
		private var _animations:Object;/**AnimationHelper**/
		// temporary data
		private var _polygons:Vector.<String>;
		private var _transforms:Vector.<Transformation>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFFile(signature:String, charSet:String)
		{
			super(signature, charSet);
			_header = new MAFHeader();
			_animations = {};/**AnimationStruct**/
			_transforms = new <Transformation>[];
			_polygons = new <String>[];
		}

		public function addAnimation(name:String, animation:AnimationHelper):void
		{
			_animations[name] = animation;
			//TODO valid animation
		}

		/**
		 * Finalize MAF file.
		 * Write all data to file bytes.
		 *
		 * @throws flash.errors.IllegalOperationError Header contains 0 type of size fields
		 * @throws flash.errors.IllegalOperationError Modification date can not be null
		 * @throws flash.errors.IllegalOperationError Animations was not set
		 */
		override public function finalize():void
		{
			//validate header
			if(_header.colorSize == 0 || _header.frameSize == 0 || _header.matrixSize == 0)
				throw new IllegalOperationError("Header contains 0 type of size fields");
			if(_header.modificationDate == 0)
				throw new IllegalOperationError("Modification date can not be null");
			//validate data
			var n:String;
			var empty:Boolean = true;
			for(n in _animations){ empty = false; break; }
			if(empty)
				throw new IllegalOperationError("Animations was not set");
			//finalize
			this.writeHeader();
			this.writeAnimations();
			//
			_header = new MAFHeader();
			_animations = {};
			super.finalize();
		}

		override public function clear():void
		{
			_header = new MAFHeader();
			_animations = {};
			super.clear();
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		protected final function addHeader(matrixSize:int, colorSize:int, frameSize:int):void
		{
			_header.matrixSize = matrixSize;
			_header.colorSize = colorSize;
			_header.frameSize = frameSize;
			_header.modificationDate = new Date().getTime();
		}

		private function writeAnimations():void
		{
			this.position = MAFHeaderFormat.HEADER_SIZE;
			for(var name:String in _animations)
			{
				var animation:AnimationHelper = _animations[name];
				this.collectData(animation);
				this.writeAnimationHeader(name, animation);
				this.writePolygons();
				this.writeTransformations();
				this.writeFrames(animation);
			}
			this.writeByte(ControlCharacters.EOF);
		}

		private function collectData(animation:AnimationHelper):void
		{
			_polygons.length = 0;
			_transforms.length = 0;
			var n:int = animation.frames.length;
			for(var i:int = 0; i < n; ++i)
			{
				var index:int;
				var frame:FrameInfo = animation.frames[i];
				if(frame.isEmpty)continue;
				//save polygon if was not saved
				index = _polygons.indexOf(frame.polygonName);
				if(index < 0)_polygons.push(frame.polygonName);
				//save transformations
				index = _transforms.indexOf(frame.m0);
				if(index < 0)_transforms.push(frame.m0);
				if(frame.isMotion)
				{
					index = _transforms.indexOf(frame.m1);
					if(index < 0)_transforms.push(frame.m1);
				}
			}
		}

		private function writeAnimationHeader(name:String, animation:AnimationHelper):void
		{
			this.writeByte(ControlCharacters.DLE);
			this.writeShort(name.length);
			this.writeMultiByte(name, this.charSet);
			this.writeBounds(animation.bounds);
			this.writeShort(animation.numLayers);
			this.writeShort(animation.totalFrames);
			this.writeShort(_transforms.length);
			this.writeShort(_polygons.length);
		}

		private function writePolygons():void
		{
			var n:int = _polygons.length;
			for(var i:int = 0; i < n; ++i)
			{
				var name:String = _polygons[i];
				this.writeShort(name.length);
				this.writeMultiByte(name, this.charSet);
			}
		}

		private function writeTransformations():void
		{
			var n:int = _transforms.length;
			for(var i:int = 0; i < n; ++i)
			{
				var t:Transformation = _transforms[i];
				this.writeMatrix(t.matrix);
				this.writeColor(t.color);
			}
		}

		private function writeFrames(animation:AnimationHelper):void
		{
			var n:int = animation.frames.length;
			for(var i:int = 0; i < n; ++i)
			{
				var frame:FrameInfo = animation.frames[i];
				if(frame.isEmpty)
					this.writeByte( FrameType.EMPTY );
				else{
					var index:int;
					this.writeByte( frame.isMotion ? FrameType.MOTION : FrameType.STATIC );
					index = _polygons.indexOf( frame.polygonName );
					this.writeShort(index);
					index = _transforms.indexOf( frame.m0 );
					this.writeShort(index);
					index = frame.isMotion ? _transforms.indexOf( frame.m1 ) : -1;
					this.writeShort(index);
					this.writeFloat(frame.t);
				}
			}
		}
		//Tools
		private final function writeBounds(bounds:Rectangle):void
		{
			this.writeFloat(bounds.x);
			this.writeFloat(bounds.y);
			this.writeFloat(bounds.width);
			this.writeFloat(bounds.height);
		}

		/**
		 * Write transformation matrix to file
		 * @param matrix Transformation matrix
		 */
		[Inline]
		private final function writeMatrix(matrix:TransformMatrix):void
		{
			this.writeFloat(matrix.offsetX);
			this.writeFloat(matrix.offsetY);
			this.writeFloat(matrix.scaleX);
			this.writeFloat(matrix.scaleY);
			this.writeFloat(matrix.skewX);
			this.writeFloat(matrix.skewY);
			this.writeFloat(matrix.tx);
			this.writeFloat(matrix.ty);
		}

		/**
		 * Write color transformation to file
		 * @param color Color transformation
		 */
		[Inline]
		private final function writeColor(color:Color):void
		{
			this.writeByte(color.type);
			this.position++;//reserved byte, to be in odd order
			/**
			 * Colors will be converted to gap from -255 to 255.
			 * (May be gap from -127 to 127(1 byte) will be fine)
			 */
			this.writeShort(color.alphaOffset * 255);
			this.writeShort(color.alphaMultiplier * 255);
			this.writeShort(color.redOffset * 255);
			this.writeShort(color.redMultiplier * 255);
			this.writeShort(color.greenOffset * 255);
			this.writeShort(color.greenMultiplier * 255);
			this.writeShort(color.blueOffset * 255);
			this.writeShort(color.blueMultiplier * 255);
		}

		//write to file
		private function writeHeader():void
		{
			this.writeMultiByte(this.signature, this.charSet);
			this.position = MAFHeaderFormat.MT;
			this.writeShort(_header.matrixSize);
			this.position = MAFHeaderFormat.CT;
			this.writeShort(_header.colorSize);
			this.position = MAFHeaderFormat.FT;
			this.writeShort(_header.frameSize);
			this.position = MAFHeaderFormat.DATE;
			this.writeInt(_header.modificationDate);//Write creation time
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