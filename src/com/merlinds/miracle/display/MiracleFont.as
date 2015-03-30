/**
 * User: MerlinDS
 * Date: 05.12.2014
 * Time: 11:57
 */
package com.merlinds.miracle.display {

	import com.merlinds.miracle.animations.FrameInfo;

	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	public class MiracleFont extends MiracleDisplayObject {

		public static const FONT_POSTFIX:String = ".font";

		private var _text:String;

		public var glyphSize:int;

		private var _xInterval:int;
		private var _yInterval:int;
		private var _xSpace:int;
		private var _markForUpdate:Boolean;

		protected var _glyphs:Object;
		private var _buffer:ByteArray;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleFont() {
			super();
			_buffer = new ByteArray();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		override protected function afterAnimationDemand():void {
			_glyphs = {};
			var k:int = this.animation.indexOf(FONT_POSTFIX);
			k = this.animation.substr(0, k).length + 1;
			var n:int = this.animationInstance.frames.length;
			for(var i:int = 0; i < n; i++){
				var glyph:FrameInfo = this.animationInstance.frames[i];
				var name:String = "0x"+glyph.polygonName.substr(k);
				_glyphs[uint(name)] = glyph;
			}
			this.animationInstance.frames.length = 0;
			this.animationInstance.totalFrames = 1;
			if(_text != null && _text.length > 0){
				this.update();
			}
			this.visible = false;
		}

		[Inline]
		private final function update():void {
			_buffer.clear();
			this.animationInstance.numLayers = 0;
			this.animationInstance.frames.length = 0;
			this.visible = false;
			//update glyphs
			if(_text == null ||  _text.length == 0)return;
			_buffer.writeUTFBytes(_text);
			_buffer.position = 0;
			if(_xInterval == 0)
				_xInterval = this.glyphSize;
			if(_xSpace == 0)
				_xSpace = this.glyphSize;
			var x:int = 0, y:int = 0;
			var n:int = _buffer.length;
			for(var i:int = 0; i < n; i++){
				var char:uint = _buffer.readByte();
				var glyph:FrameInfo = _glyphs[ char ];
				if(glyph != null){
					glyph = glyph.clone();
					glyph.m0.matrix.tx = x;
					glyph.m0.matrix.ty = y;
					this.animationInstance.frames.push(glyph);
					this.animationInstance.numLayers++;
				}else{
					if(char == 0x9)
					{
						x = -_xInterval;
						y += _yInterval;
					}else if(char == 0x20)
					{
						x -= _xInterval;
						x += _xSpace;
					}

				}
				x += _xInterval;

			}
			this.visible = true;
			_markForUpdate = false;
		}

		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS

		public function get text():String {
			return _text;
		}

		public function set text(value:String):void {
			if(value != _text){
				_text = value;
				if(value == null || value.length == 0){
					this.visible = false;
				}else{
					if(_glyphs != null){
						this.update();
					}
				}
			}
		}

		public function get xInterval():int
		{
			return _xInterval;
		}

		public function set xInterval(value:int):void
		{
			_xInterval = value;
			if(!_markForUpdate && _text != null && _text.length > 0)
			{
				setTimeout(this.update, 0);
				_markForUpdate = true;
			}
		}

		public function get yInterval():int
		{
			return _yInterval;
		}

		public function set yInterval(value:int):void
		{
			_yInterval = value;
			if(!_markForUpdate && _text != null && _text.length > 0)
			{
				setTimeout(this.update, 0);
				_markForUpdate = true;
			}
		}

		public function get xSpace():int
		{
			return _xSpace;
		}

		public function set xSpace(value:int):void
		{
			_xSpace = value;
			if(!_markForUpdate && _text != null && _text.length > 0)
			{
				setTimeout(this.update, 0);
				_markForUpdate = true;
			}
		}

		override public function set visible(value:Boolean):void
		{
			if(_text == null || _text.length == 0)super .visible = false;
			else super.visible = value;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
