/**
 * Created by MerlinDS on 31.03.2015.
 */
package com.merlinds.miracle.fonts
{

	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.miracle_internal;

	use namespace miracle_internal;

	public class MiracleFonts
	{
		//main control symbols
		public static const TAB:uint = 0x9;
		public static const NEXT_LINE:uint = 0xA;
		public static const SPACE:uint = 0x20;
		//
		public static const FONT_POSTFIX:String = ".font";
		//
		private static const _fonts:Object = {};
		//======================================================================================================================
//{region											PUBLIC METHODS
		public function MiracleFonts()
		{
		}

		miracle_internal static function updateGlyphs(name:String, animationInstance:AnimationHelper):void
		{
			if(_fonts[name] == null)
			{
				var glyphs:GlyphsMap = new GlyphsMap(animationInstance.bounds.width, animationInstance.bounds.height);
				var k:int = name.indexOf(FONT_POSTFIX);
				k = name.substr(0, k).length + 2;
				var n:int = animationInstance.frames.length;
				for(var i:int = 0; i < n; i++){
					var glyph:FrameInfo = animationInstance.frames[i];
					var glyphName:String = "0x" + glyph.polygonName.substr(k);
					glyphs[uint( glyphName )] = glyph;
				}
				_fonts[name] = glyphs;
			}
		}

		miracle_internal static function getGlyphs(name:String, clearName:Boolean = false):GlyphsMap
		{
			if(!clearName)
			{
				var k:int = name.indexOf(FONT_POSTFIX);
				name = name.substr(0, k);
			}
			return _fonts[name];
		}
//} endregion PUBLIC METHODS ===========================================================================================
//======================================================================================================================
//{region										PRIVATE\PROTECTED METHODS

//} endregion PRIVATE\PROTECTED METHODS ================================================================================
//======================================================================================================================
//{region											GETTERS/SETTERS

//} endregion GETTERS/SETTERS ==========================================================================================
	}
}
