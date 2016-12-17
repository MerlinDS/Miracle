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
package tests.com.merlinds.miracle.utils.serializers
{
	import com.merlinds.miracle.utils.serializers.MTFSerializer;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import flexunit.framework.Assert;
	
	/**
	 * Test case for MTF serializer.
	 */
	public class MTFSerializerTest
	{
		private static const PROTOCOL_V2:uint = 0x0002;
		
		[Embed(source="MTFObjectV2.json", mimeType='application/octet-stream')]
		private static const MFTObjectV2_JSON:Class;
		
		private var _dataProvider:Dictionary;
		private var _serializer:MTFSerializer;
		
		[Before]
		public function setUp():void
		{
			_dataProvider = new Dictionary();
			try{
				var jsonHolder:Object = JSON.parse(new MFTObjectV2_JSON());
				_dataProvider[PROTOCOL_V2] = jsonHolder.data;
			}catch (error:Error)
			{
				Assert.fail("Error occurs while data provider initialization: " + error.message);
			}
		}
		
		[Test(description="MTF object serialization test, protcol version 2.0")]
		public function serializeV2Test():void
		{
			_serializer = new MTFSerializer(PROTOCOL_V2);
			var bytes:ByteArray = _serializer.serialize(_dataProvider[PROTOCOL_V2]);
			Assert.assertNotNull("Serialization failed: bytes", bytes);
			
		}
	}
}