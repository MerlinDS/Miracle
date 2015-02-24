/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 19:31
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.AnimationHelper;
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
		private var _animation:AnimationHelper;
		private var _layers:Vector.<LayerHelper>;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFReader(signature:String, bytesChunk:int = 8960) {
			this.addReadingMethod(this.readAnimationHeader);
			this.addReadingMethod(this.readLayer);
			this.addReadingMethod(this.readTransform);
			this.addReadingMethod(this.readFrame);
			this.addReadingMethod(this.completeAnimation);
			super(signature, bytesChunk);
		}

		override public function read(bytes:ByteArray, ...args):void {
			super.read(bytes, args);
			_animations = args[0];
		}

		override public function dispose():void {
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

		private function readAnimationHeader():void {
			assert(this.bytes.readByte() == ControlCharacters.DLE, ReaderError.BAD_ANIMATION_HEADER);
			if(this.status != ReaderStatus.ERROR)
			{
				var length:int = this.bytes.readShort();
				var name:String = this.bytes.readMultiByte(length, this.charSet);
				var bounds:Rectangle = new Rectangle();
				bounds.x = this.bytes.readFloat();
				bounds.y = this.bytes.readFloat();
				bounds.width = this.bytes.readFloat();
				bounds.height = this.bytes.readFloat();
				var totalFrames:int = this.bytes.readShort();
				var numLayers:int = this.bytes.readShort();
				var frames:Vector.<FrameInfo> = new <FrameInfo>[];
				frames.length = totalFrames;
				_animation = new AnimationHelper(name, totalFrames, numLayers, frames);
				_animation.bounds = bounds;
				_layers = new <LayerHelper>[];
			}
			this.methodEnded();
		}

		private function readLayer():void {
			if(_layers.length < _animation.numLayers)
			{
				assert(this.bytes.readByte() == ControlCharacters.GS, ReaderError.BAD_LAYER_HEADER);
				if(this.status != ReaderStatus.ERROR)
				{
					var layerHelper:LayerHelper = new LayerHelper(
							this.bytes.readShort(),
							this.bytes.readShort());
					while(this.bytes.readByte() != ControlCharacters.RS)//can be a problem
					{
						this.bytes.position--;
						var length:int = this.bytes.readShort();
						layerHelper.polygons.push(this.bytes.readMultiByte(length, this.charSet));
					}
					_layers.push(layerHelper);
				}
				this.methodEnded();
			}else
			{
				this.methodEnded(this.completeAnimation);
			}
		}

		private function readTransform():void
		{
			var layer:LayerHelper = _layers[_layers.length - 1];
			if(layer.transformations.length < layer.tLength)
			{
				var matrix:TransformMatrix = new TransformMatrix();
				matrix.offsetX = this.bytes.readFloat();
				matrix.offsetY = this.bytes.readFloat();
				matrix.scaleX = this.bytes.readFloat();
				matrix.scaleY = this.bytes.readFloat();
				matrix.skewX = this.bytes.readFloat();
				matrix.skewY = this.bytes.readFloat();
				matrix.tx = this.bytes.readFloat();
				matrix.ty = this.bytes.readFloat();
				//
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

				layer.transformations.push(new Transformation(matrix, color))
			}
			else
			{
				this.methodEnded();
			}
		}

		private function readFrame():void {
			var layer:LayerHelper = _layers[_layers.length - 1];
			if(layer.frames.length < layer.fLength)
			{
				var frame:FrameHelper = new FrameHelper();
				frame.type = this.bytes.readByte();
				if(frame.type != FrameType.EMPTY)
				{
					frame.polygonIndex = this.bytes.readShort();
					frame.transformIndex = this.bytes.readShort();
					frame.t = this.bytes.readFloat();
				}
				layer.frames.push(frame);
			}
			else
			{
				//Go to next layer
				this.methodEnded(this.readLayer);
			}
		}

		private function completeAnimation():void {
			if(this.bytes.readByte() != ControlCharacters.EOF)
			{
				this.bytes.position--;
				this.methodEnded(this.readAnimationHeader);
			}
			else
			{
				this.methodEnded();
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

import com.merlinds.miracle.geom.Transformation;

class LayerHelper
{
	public var tLength:int;
	public var fLength:int;
	public var polygons:Vector.<String>;
	public var transformations:Vector.<Transformation>;
	public var frames:Vector.<FrameHelper>;

	public function LayerHelper(tLength:int, fLength:int) {
		this.tLength = tLength;
		this.fLength = fLength;
		this.polygons = new <String>[];
		this.transformations = new <Transformation>[];
		this.frames = new <FrameHelper>[];
	}
}

class FrameHelper
{
	public var type:uint;
	public var polygonIndex:int;
	public var transformIndex:int;
	public var t:Number;
}