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

package com.merlinds.miracle.utils.serializers.MTF
{
	import com.merlinds.miracle.utils.serializers.*;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * his is the factory class for provide public API of MTFSerializer.
	 */
	public class MTFSerializer extends SerializerWrapper implements IMTFSerializer
	{
		
		/**
		 * Constructor
		 * @param useDefault If true, will be used default serializer instead of throwing error.
		 */
		public function MTFSerializer(useDefault:Boolean = false)
		{
			var dictionary:Dictionary = new Dictionary();
			dictionary[ MSVersions.MTF2 ] = MTFSerializerV2;
			super (dictionary, useDefault, MSVersions.MTF2);
		}
		
		/**
		 * @inheritDoc
		 */
		public function serialize(data:Object, version:uint):ByteArray
		{
			var serialize:IMTFSerializer = getSerializerByVersion(version) as IMTFSerializer;
			return serialize.serialize( data, version );
		}
		
		/**
		 * Version will be detected automatically
		 * @inheritDoc
		 */
		public function deserialize(bytes:ByteArray, output:Dictionary,
									scale:Number, alias:String, callback:Function):void
		{
			var serialize:IMTFSerializer = getSerializerBySignature(bytes) as IMTFSerializer;
			serialize.deserialize( bytes, output, scale, alias, callback );
		}
	}
}
