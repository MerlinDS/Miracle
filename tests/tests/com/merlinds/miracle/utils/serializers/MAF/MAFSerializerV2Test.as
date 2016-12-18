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

package tests.com.merlinds.miracle.utils.serializers.MAF
{
	import com.merlinds.miracle.utils.serializers.MAF.MAFSerializer;
	import com.merlinds.miracle.utils.serializers.MSVersions;
	
	import flash.utils.ByteArray;
	
	import flash.utils.Dictionary;
	
	import flexunit.framework.Assert;
	
	public class MAFSerializerV2Test
	{
		private static const SIGNATURE:String = "MAF";
		
		[Embed(source="MAFObjectV2.json", mimeType='application/octet-stream')]
		private static const MFTObjectV2_JSON:Class;
		
		private var _dataProvider:Dictionary;
		private var _serializer:MAFSerializer;
		
		[Before]
		public function setUp():void
		{
			_dataProvider = new Dictionary();
			try
			{
				var jsonHolder:Object = JSON.parse( new MFTObjectV2_JSON() );
				_dataProvider[ MSVersions.MAF2 ] = new TestDataHolder( jsonHolder.data );
			} catch ( error:Error )
			{
				Assert.fail( "Error occurs while data provider initialization: " + error.message );
			}
			_serializer = new MAFSerializer();
		}
		
		[After]
		public function tearDown():void
		{
			_dataProvider = null;
			_serializer = null;
		}
		
		
		[Test(description="MAF object serialization test")]
		public function testSerialize():void
		{
			var holder:TestDataHolder = _dataProvider[ MSVersions.MAF2 ];
			var bytes:ByteArray = _serializer.serialize(holder.data, MSVersions.MAF2);
			Assert.assertNotNull( "Serialization failed: bytes", bytes );
			Assert.assertTrue( "Serialization failed: bytes array empty", bytes.length > 4 );
			signatureAssert( "Serialization failed: signature failed", bytes );
			//test by indirect signs
			var totalSize:int = 8 + 4 + //Signature size + length
					holder.dictSize +
					0;//
			Assert.assertTrue( "Serialization failed: bytes length", totalSize < bytes.length );
		}
		
		[Inline]
		private final function signatureAssert(message:String, bytes:ByteArray):void
		{
			var signature:String = String.fromCharCode( bytes[ 0 ], bytes[ 1 ], bytes[ 2 ] );
			Assert.assertEquals( message, SIGNATURE, signature );
		}
	}
}

import com.merlinds.miracle.utils.serializers.DictionarySerializer;

import flash.utils.Endian;

class TestDataHolder
{
	public var data:Object;
	public var dictSize:int;
	
	
	public function TestDataHolder(data:Object)
	{
		this.data = data;
		
		dictSize = new DictionarySerializer('us-ascii', Endian.LITTLE_ENDIAN)
				.serializeFromObject(data, false).length;
	}
}
