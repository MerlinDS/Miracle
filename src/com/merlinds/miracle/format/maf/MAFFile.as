/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 18:46
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.format.FormatFile;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flash.errors.IllegalOperationError;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class MAFFile extends FormatFile {

		private var _header:MAFHeader;
		private var _animations:Object;/**AnimationStruct**/
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFFile(signature:String, charSet:String) {
			super(signature, charSet);
			_header = new MAFHeader();
			_animations = {};/**AnimationStruct**/
		}

		public function addAnimation(name:String, bounds:Rectangle):void {
			var animation:AnimationStruct = new AnimationStruct();
			animation.header.writeByte(ControlCharacters.DLE);
			animation.header.writeShort(name.length);
			animation.header.writeMultiByte(name, this.charSet);
			//write bounds
			animation.header.writeFloat(bounds.x);
			animation.header.writeFloat(bounds.y);
			animation.header.writeFloat(bounds.width);
			animation.header.writeFloat(bounds.height);
			//
			_animations[name] = animation;
		}

		/**
		 *
		 * Add transformation object to file
		 * @param animationName Animation name.
		 * Must be set previously by addAnimation() method!
		 * @param layerIndex Index of the layer in animation.
		 * @param transformation Transformation object
		 *
		 * @throws ArgumentError Can't add transformation to unknown animation.
		 */
		public function addTransformation(animationName:String, layerIndex:int,
		                                  transformation:Transformation):void {
			if(!_animations.hasOwnProperty(animationName))
				throw new ArgumentError("Can't add transformation to unknown animation");
			var animation:AnimationStruct = _animations[animationName];
			var layer:LayerStruct = this.extendLayers(animation, layerIndex);
			var bytes:ByteArray = new ByteArray();
			this.writeMatrix(transformation.matrix, bytes);
			this.writeColor(transformation.color, bytes);
			//may be will need a transformation id
			layer.transformations.push(bytes);
		}

		/**
		 * Add frame to animation
		 * @param animationName Animation name.
		 * Must be set previously by addAnimation() method!
		 * @param layerIndex Index of the layer in animation.
		 * @param polygonName Name of the polygon in texture that will be linked to this frame
		 * @param type Type of the animation: true - motion, false - static
		 * @param index Index of transformation object the will be linked to this frame
		 * @param t Global time of the animation for this frame (gap from 0 to 1)
		 *
		 * @throws ArgumentError Can't add transformation to unknown animation.
		 */
		public function addFrame(animationName:String, layerIndex:int,
		                         polygonName:String, type:Boolean, index:int, t:Number):void {

			if(!_animations.hasOwnProperty(animationName))
				throw new ArgumentError("Can't add transformation to unknown animation");
			var animation:AnimationStruct = _animations[animationName];
			var layer:LayerStruct = this.extendLayers(animation, layerIndex);
			//get polygonName index if it already added
			var pIndex:int = layer.polygons.indexOf(polygonName);
			if(pIndex < 0)
				layer.polygons.push(polygonName);

			var bytes:ByteArray = new ByteArray();
			bytes.writeBoolean(type);
			bytes.position++;//reserved byte, to be in odd order
			bytes.writeShort(pIndex);
			bytes.writeShort(index);
			bytes.writeFloat(t);
			layer.frames.push(bytes);
		}

		/**
		 * Finalize MAF file.
		 * Write all data to file bytes.
		 *
		 * @throws flash.errors.IllegalOperationError Header contains 0 type of size fields
		 * @throws flash.errors.IllegalOperationError Modification date can not be null
		 * @throws flash.errors.IllegalOperationError Animations was not set
		 */
		override public function finalize():void {
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

		override public function clear():void {
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

		/**
		 * Extends layer in animation struct if it does not exist, and return Layer Struct.
		 * @param animation Animation Struct
		 * @param layerIndex Layer index
		 * @return Layer Structure
		 */
		private function extendLayers(animation:AnimationStruct, layerIndex:int):LayerStruct {
			if(animation.layers.length <= layerIndex)//extends layer array
				animation.layers.length = layerIndex + 1;
			var layer:LayerStruct = new LayerStruct();
			animation.layers[layerIndex] = layer;
			return layer;
		}

		/**
		 * Write transformation matrix to byte array
		 * @param matrix Transformation matrix
		 * @param bytes Target byte array
		 */
		[Inline]
		private final function writeMatrix(matrix:TransformMatrix, bytes:ByteArray):void
		{
			bytes.position = 0;
			bytes.writeFloat(matrix.offsetX);
			bytes.writeFloat(matrix.offsetY);
			bytes.writeFloat(matrix.scaleX);
			bytes.writeFloat(matrix.scaleY);
			bytes.writeFloat(matrix.skewX);
			bytes.writeFloat(matrix.skewY);
			bytes.writeFloat(matrix.tx);
			bytes.writeFloat(matrix.ty);
		}

		/**
		 * Write color transformation to byte array
		 * @param color Color transformation
		 * @param bytes Target byte array
		 */
		[Inline]
		private final function writeColor(color:Color, bytes:ByteArray):void
		{
			bytes.position = _header.matrixSize;
			bytes.writeByte(color.type);
			bytes.position++;//reserved byte, to be in odd order
			/**
			 * Colors will be converted to gap from -255 to 255.
			 * (May be gap from -127 to 127(1 byte) will be fine)
			 */
			bytes.writeShort(color.alphaOffset * 255);
			bytes.writeShort(color.alphaMultiplier * 255);
			bytes.writeShort(color.redOffset * 255);
			bytes.writeShort(color.redMultiplier * 255);
			bytes.writeShort(color.greenOffset * 255);
			bytes.writeShort(color.greenMultiplier * 255);
			bytes.writeShort(color.blueOffset * 255);
			bytes.writeShort(color.blueMultiplier * 255);
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

		private function writeAnimations():void
		{
			this.position = MAFHeaderFormat.HEADER_SIZE;
			for each(var animation:AnimationStruct in _animations)
			{
				animation.header.position = 0;
				this.writeBytes(animation.header, 0, animation.header.length);
				this.writeShort(animation.layers.length);
			}
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

import flash.utils.ByteArray;

//helpers struct
	class LayerStruct{
	public var polygons:Vector.<String>;
	public var transformations:Vector.<ByteArray>;
	public var frames:Vector.<ByteArray>;


	public function LayerStruct() {
		polygons = new <String>[];
		transformations = new <ByteArray>[];
		frames = new <ByteArray>[];
	}
}

class AnimationStruct{
	public var header:ByteArray;
	public var layers:Vector.<LayerStruct>;

	public function AnimationStruct() {
		this.header = new ByteArray();
		this.layers = new <LayerStruct>[];
	}
}