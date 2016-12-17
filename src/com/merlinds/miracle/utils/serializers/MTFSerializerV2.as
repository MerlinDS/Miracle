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

/**
 * Created by merli on 17.12.2016.
 */
package com.merlinds.miracle.utils.serializers
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * MTF (Miracle texture format) serializer.
	 * Protocol version 2.0
	 *
	 * @inheritDoc
	 */
	internal class MTFSerializerV2 extends MTFSerializer
	{
		public function MTFSerializerV2()
		{
			super( MTFSerializer.V2, Endian.LITTLE_ENDIAN );
		}
		
		
		/**
		 * Concrete serialization method realization
		 * @param data Data object than need to be serialized.
		 * @example
		 * //Data object structure
		 *
		 * [{
		 * 	mesh:[
		 * 		//list of parts
		 * 		{
		 * 			name:[name of the polygon],
		 * 			indexes:[0,3,1,2,1,3],
		 * 			uv:[8 values of UV coordinates ],
		 *			vertices:[8 values of vertices coordinates]
		 * 		}]
		 * 	},
		 * 	...
		 * ]
		 *
		 * @param output <code>ByteArray</code> of serialized MTF
		 */
		override protected function executeSerialization(data:Object, output:ByteArray):void
		{
			
		}
	}
}
