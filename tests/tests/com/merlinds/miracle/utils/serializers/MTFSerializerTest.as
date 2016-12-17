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
		private static const SIGNATURE:String = "MTF";
		
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
				_dataProvider[MTFSerializer.V2] = new TestDataHolder(jsonHolder.data);
			}catch (error:Error)
			{
				Assert.fail("Error occurs while data provider initialization: " + error.message);
			}
		}
		
		[Test(expects="ArgumentError", description="MTF serialization instantiation errror of protocol versio")]
		public function instantiationErrorTest():void
		{
			//Try to instantiate wrong version
			MTFSerializer.createSerializer(0x0000);
		}
		
		[Test(description="MTF object serialization test")]
		public function serializeTest():void
		{
			_serializer = MTFSerializer.createSerializer(MTFSerializer.V2);
			var holder:TestDataHolder = _dataProvider[MTFSerializer.V2];
			var bytes:ByteArray = _serializer.serialize(holder.data);
			Assert.assertNotNull("Serialization failed: bytes", bytes);
			Assert.assertTrue("Serialization failed: bytes array empty", bytes.length > 4);
			signatureAssert("Serialization failed: signature failed", bytes);
			//test by indirect signs
			var totalSize:int = _serializer.signatureBytes.length +
							holder.meshesCount * 72 +// header size
							holder.polygonsCount * 128;//polygons list size
			Assert.assertEquals("Serialization failed: bytes length", totalSize, bytes.length);
		}
		
		[Inline]
		private final function signatureAssert(message:String, bytes:ByteArray):void
		{
			var signature:String = String.fromCharCode(bytes[0], bytes[1], bytes[2]);
			Assert.assertEquals(message, SIGNATURE, signature);
		}
	}
}
class TestDataHolder
{
	public var data:Object;
	public var meshesCount:int;
	public var polygonsCount:int;
	
	
	public function TestDataHolder(data:Object)
	{
		this.data = data;
		meshesCount = data.length;
		for each(var mesh:Object in data)
			polygonsCount += mesh.mesh.length;
	}
}