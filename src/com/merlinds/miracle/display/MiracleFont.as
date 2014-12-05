/**
 * User: MerlinDS
 * Date: 05.12.2014
 * Time: 11:57
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.animations.EmptyFrameInfo;
	import com.merlinds.miracle.animations.FrameInfo;

	public class MiracleFont extends MiracleDisplayObject {

		private var _text:String;
		private var _glyphs:Object;

		public var glyphSize:int;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleFont() {
			super();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		override protected function afterAnimationDemand():void {
			_glyphs = {};
			var k:int = this.animation.length - 4;
			var n:int = this.animationInstance.frames.length;
			for(var i:int = 0; i < n; i++){
				var glyph:FrameInfo = this.animationInstance.frames[i];
				var name:String = glyph.polygonName.substr(k);
				_glyphs[name] = glyph;
			}
			this.animationInstance.frames.length = 0;
			this.animationInstance.totalFrames = 1;
			if(_text != null && _text.length > 0){
				this.update();
			}
			this.visible = false;
		}

		private final function update():void {
			var chars:Array = _text.split("");
			this.visible = false;
			this.animationInstance.frames.length = chars.length;
			//update glyphs
			var n:int = chars.length;
			for(var i:int = 0; i < n; i++){
				var char:String = chars[i];
				var glyph:FrameInfo = _glyphs[ char ];
				if(glyph != null){
					glyph = glyph.clone();
					glyph.m0.matrix.tx = this.glyphSize * i;
				}else{
					glyph = new EmptyFrameInfo();
				}
				this.animationInstance.frames[i] = glyph;
			}
			this.animationInstance.numLayers = n;
			chars.length = 0;
			this.visible = true;
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
					this.visible = true;
				}else{
					if(_glyphs != null){
						this.update();
					}
				}
			}
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
