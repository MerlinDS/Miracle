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

package com.merlinds.miracle.utils.serializers.MAF
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * Public interface for MTF serializers (Miracle animation format)
	 */
	internal interface IMAFSerialize
	{
		/**
		 * Serialize data to MAF (Miracle animation format) <code>ByteArray</code>
		 * @param data Data object than need to be serialized
		 * @param version Version Protocol for serialization
		 * @return <code>ByteArray</code> of MAF
		 */
		function serialize(data:Object, version:uint):ByteArray;
		
		/**
		 * Deserialize <code>ByteArray</code> with MAF to Miracle animation data
		 * @param bytes Bytes for deserialization
		 * @param output Output dictionary
		 * @param scale Global scene scale (need for Polygon building)
		 * @param alias Texture alias for animations
		 * @param callback Deserialization complete callback method
		 */
		function deserialize(bytes:ByteArray, output:Dictionary,
							scale:Number, alias:String,
							callback:Function):void;
	}
}
