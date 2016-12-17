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
	
	/**
	 * MTF (Miracle texture format) serializer
	 */
	public class MTFSerializer
	{
		//region Properties
		private var _version:int;
		private var _callback:Function;
		//endregion
		/**
		 * Constructor
		 * @param version of serialization protocol
		 */
		public function MTFSerializer(version:uint)
		{
			_version = version;
		}
		
		//region Public
		/**
		 * Serialize data to MTF (Miracle texture format) <code>ByteArray</code>
		 * @param data Data object than need to be serialized
		 * @return <code>ByteArray</code> of MTF file
		 */
		public function serialize(data:Object):ByteArray
		{
			return null;
		}
		
		/**
		 * Deserialize <code>ByteArray</code> with MTF to Miracle texture data
		 * @param bytes Bytes for deserialization
		 * @param callback Deserialization complete callback method
		 */
		public function deserialize(bytes:ByteArray, callback:Function):void
		{
			_callback = callback;
		}
		
		/**
		 * @inheritDoc
		 */
		public function toString():String
		{
			return "MTFSerializer{Protocol version=" + _version + "}";
		}
		
		//endregion
		
		
	}
}
