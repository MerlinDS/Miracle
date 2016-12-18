/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2016. Near Fancy
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package com.merlinds.miracle.utils.serializers
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Serializer for dictionary of aliases.
	 */
	public class DictionarySerializer
	{
		//region Properties
		private var _endian:String;
		private var _charSet:String;
		//endregion
		
		/**
		 * Constructor
		 * @param charSet Characters set
		 * @param endian Endian of bytes
		 */
		public function DictionarySerializer(charSet:String, endian:String = Endian.LITTLE_ENDIAN)
		{
			_charSet = charSet;
			_endian = endian;
		}
		
		//region Public
		/**
		 * Serialize aliases to bytes dictionary
		 * @param aliases List of aliases
		 * @return <code>ByteArray</code> of dict
		 */
		public function serialize(aliases:Vector.<String>):ByteArray
		{
			if(aliases == null)
				throw new ArgumentError("Aliases null");
			var output:ByteArray = new ByteArray();
			output.endian = _endian;
			var n:int = aliases.length;
			for(var i:int = 0; i < n; ++i)
			{
				var word:String = aliases[i];
				output.writeInt(word.length);
				output.writeMultiByte(word, _charSet);
			}
			output.writeInt(0);//End of dict
			return output;
		}
		
		/**
		 * Deserialize aliases from bytes dict
		 * @param bytes <code>ByteArray</code> of dict
		 * @return List of aliases
		 */
		public function deserialize(bytes:ByteArray):Vector.<String>
		{
			if(bytes == null || bytes.length == 0)
				throw new ArgumentError("BytesArray null or has 0 length");
			var output:Vector.<String> = new <String>[];
			bytes.endian = _endian;
			var length:int;
			while (length = bytes.readInt())
			{
				output.push(
					bytes.readMultiByte(length, _charSet)
				);
			}
			return output;
		}
		//endregion
	}
}
