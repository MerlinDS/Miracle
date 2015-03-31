/**
 * User: MerlinDS
 * Date: 05.12.2014
 * Time: 11:57
 */
package com.merlinds.miracle.fonts
{

	import com.merlinds.miracle.display.*;

	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.EmptyFrameInfo;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.miracle_internal;

	import flash.geom.Rectangle;

	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	public class MiracleText extends MiracleDisplayObject
	{

		private var _textLines:Vector.<TextLine>;
		private var _biggestLineSize:int;

		private var _glyphs:GlyphsMap;
		private var _buffer:ByteArray;

		private var _text:String;
		private var _markForUpdate:Boolean;

		private var _xInterval:int;
		private var _yInterval:int;
		private var _space:int;
		private var _align:uint;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleText()
		{
			super();
			_buffer = new ByteArray();
			this.animationInstance = new AnimationHelper(null, 1, 1,
					new <FrameInfo>[new EmptyFrameInfo()]);
			this.animationInstance.bounds = new Rectangle(0, 0, 1, 1);
			_align = MiracleTextAlign.LEFT;
			_textLines = new <TextLine>[ ];
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS

		private function initializeUpdate():void
		{
			if (_text == null || _text.length == 0)
			{
				this.visible = false;
			}
			else
			{
				this.clearOldData();
				this.updateGlyphs();
				this.alignText();
			}
		}

		private function getTextLine(index:int):TextLine
		{
			while(_textLines.length <= index)
				_textLines[_textLines.length] = new TextLine(_xInterval, _space);
			_textLines[index].glyphSize = _xInterval;
			_textLines[index].spaceSize = _space;
			return _textLines[index];
		}

		[Inline]
		private final function updateGlyphs():void
		{
			if (_text == null || _text.length == 0)return;
			_buffer.writeUTFBytes(_text);
			_buffer.position = 0;

			var n:int = _buffer.length;
			var index:int = 0;
			var textLine:TextLine = this.getTextLine(index);
			for (var i:int = 0; i < n; i++)
			{
				var char:uint = _buffer.readByte();
				var glyph:FrameInfo = _glyphs[char];
				if (glyph)
				{
					glyph = glyph.clone();//TODO add glyphs pooling
					textLine.push(this.animationInstance.frames.length, char);
					this.animationInstance.frames.push(glyph);
					this.animationInstance.numLayers++;
				}else
				{
					if(char	== MiracleFonts.NEXT_LINE)
					{
						//line with biggest length become and anchor line
						if(textLine.size > _biggestLineSize)
							_biggestLineSize = textLine.size;
						//change to next line
						textLine = this.getTextLine(++index);
					}
					else
						textLine.push(-1, char);
				}


			}
			this.visible = true;
			_markForUpdate = false;
		}

		[Inline]
		private final function alignText():void
		{
			var x:int, y:int;
			var i:int, j:int, n:int, m:int;
			var char:uint;
			var offset:Number;
			var glyph:FrameInfo;
			var frames:Vector.<FrameInfo> = this.animationInstance.frames;
			n = _textLines.length;
			for(i = 0; i < n; ++i)
			{
				var textLine:TextLine = _textLines[i];
				m = textLine.length;
				x = 0;
				if(_align == MiracleTextAlign.CENTER)
				{
					offset = -_biggestLineSize >> 1;
					offset += _biggestLineSize - textLine.size >> 1;
					x = offset;
				} else if(_align == MiracleTextAlign.RIGHT)
				{
					offset = -_biggestLineSize;
					offset += _biggestLineSize - textLine.size;
					x = offset;
				}
				//TODO add Right alignment
				for(j = 0; j < m; ++j)
				{
					if(textLine.glyphs[j] > -1)
					{
						glyph = frames[textLine.glyphs[j]];
						glyph.m0.matrix.tx = x;
						glyph.m0.matrix.ty = y;
						x += _xInterval;
					}
					else
					{
						char = textLine.chars[j];
						if(char == MiracleFonts.SPACE)x += _space;
						if(char == MiracleFonts.TAB)x += _space * 4;
					}
				}
				//go to next line
				y += _yInterval;
			}
		}

		[Inline]
		private final function markForUpdate():void
		{
			if (!_markForUpdate && _text != null && _text.length > 0)
			{
				setTimeout(this.initializeUpdate, 0);
				_markForUpdate = true;
			}
		}

		[Inline]
		private final function clearOldData():void
		{
			_buffer.clear();
			this.visible = false;
			this.animationInstance.numLayers = 0;
			this.animationInstance.frames.length = 0;
			if (_glyphs == null)
				_glyphs = MiracleFonts.miracle_internal::getGlyphs(this.animation);
			//refresh sizes
			if (_xInterval == 0)_xInterval = _glyphs.width;
			if (_yInterval == 0)_yInterval = _glyphs.height;
			if (_space == 0)_space = _glyphs.width;
			//clear text lines
			var n:int = _textLines.length;
			for(var i:int = 0; i < n; ++i)
				_textLines[i].clear();
		}

		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS

		public function get text():String
		{
			return _text;
		}

		public function set text(value:String):void
		{
			if (value != _text)
			{
				_text = value;
				this.markForUpdate();
			}
		}

		public function set xInterval(value:int):void
		{
			_xInterval = value;
			this.markForUpdate();
		}

		public function set yInterval(value:int):void
		{
			_yInterval = value;
			this.markForUpdate();
		}

		public function set space(value:int):void
		{
			_space = value;
			this.markForUpdate();
		}

		public function set align(value:uint):void
		{
			_align = value;
			this.markForUpdate();
		}

		override public function set visible(value:Boolean):void
		{
			if (_text == null || _text.length == 0)super.visible = false;
			else super.visible = value;
		}

//} endregion GETTERS/SETTERS ==================================================

	}
}

import com.merlinds.miracle.fonts.MiracleFonts;

class TextLine
{
	public var glyphs:Vector.<int>;
	public var chars:Vector.<uint>;
	public var length:int;
	public var size:int;

	public var glyphSize:int;
	public var spaceSize:int;

	public function TextLine(glyphSize:int = 1, spaceSize:int = 1)
	{
		this.glyphSize = glyphSize;
		this.spaceSize = spaceSize;
		this.glyphs = new <int>[];
		this.chars = new <uint>[];
	}

	public function clear():void
	{
		this.glyphs.length = 0;
		this.chars.length = 0;
		this.length = 0;
		this.size = 0;
	}

	public function push(glyph:int, char:uint):void
	{
		this.size += glyph > -1 ? this.glyphSize :
				char == MiracleFonts.TAB ? this.spaceSize * 4 : this.spaceSize;
		this.glyphs[this.length] = glyph;
		this.chars[this.length] = char;
		this.length++;

	}
}