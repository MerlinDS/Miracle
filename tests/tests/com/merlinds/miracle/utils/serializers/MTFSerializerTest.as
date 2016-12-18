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

package tests.com.merlinds.miracle.utils.serializers
{
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;
	import com.merlinds.miracle.utils.serializers.MTFSerializer;
	
	import flash.events.Event;
	
	import flash.events.EventDispatcher;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	/**
	 * Test case for MTF serializer.
	 */
	public class MTFSerializerTest extends EventDispatcher
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
			try
			{
				var jsonHolder:Object = JSON.parse( new MFTObjectV2_JSON() );
				_dataProvider[ MTFSerializer.V2 ] = new TestDataHolder( jsonHolder.data );
			} catch ( error:Error )
			{
				Assert.fail( "Error occurs while data provider initialization: " + error.message );
			}
			_serializer = MTFSerializer.createSerializer( MTFSerializer.V2 );
		}
		
		
		[After]
		public function tearDown():void
		{
			_dataProvider = null;
			_serializer = null;
		}
		
		[Test(expects="ArgumentError", description="MTF serialization instantiation errror of protocol versio")]
		public function instantiationErrorTest():void
		{
			//Try to instantiate wrong version
			MTFSerializer.createSerializer( 0x0000 );
		}
		
		[Test(description="MTF object serialization test")]
		public function serializeTest():void
		{
			var holder:TestDataHolder = _dataProvider[ MTFSerializer.V2 ];
			var bytes:ByteArray = _serializer.serialize( holder.data );
			Assert.assertNotNull( "Serialization failed: bytes", bytes );
			Assert.assertTrue( "Serialization failed: bytes array empty", bytes.length > 4 );
			signatureAssert( "Serialization failed: signature failed", bytes );
			//test by indirect signs
			var totalSize:int = _serializer.signatureBytes.length + 1 + 4 +
					holder.dictSize +
					holder.meshesCount * 12 +// header size
					holder.polygonsCount * 68;//polygons list size
			Assert.assertEquals( "Serialization failed: bytes length", totalSize, bytes.length );
			bytes.position = _serializer.signatureBytes.length + 1 + holder.dictSize;
			Assert.assertEquals( "Serialization failed: meshes count", holder.meshesCount, bytes.readInt() );
		}
		
		[Inline]
		private final function signatureAssert(message:String, bytes:ByteArray):void
		{
			var signature:String = String.fromCharCode( bytes[ 0 ], bytes[ 1 ], bytes[ 2 ] );
			Assert.assertEquals( message, SIGNATURE, signature );
		}
		
		
		[Test(async, description="MTF object deserialization test")]
		public function deserializeTest():void
		{
			var holder:TestDataHolder = _dataProvider[ MTFSerializer.V2 ];
			var passThroughData:Object = {
				holder:holder,
				output:new Dictionary()
			};
			var bytes:ByteArray = _serializer.serialize( holder.data );
			this.addEventListener( "callback",
					Async.asyncHandler( this, handleVerifyProperty, 100, passThroughData ),
					false, 0, true );
			_serializer.deserialize( bytes, passThroughData.output, 1, "aliasName", function ():void
			{
				dispatchEvent( new Event( 'callback' ) );
			} );
		}
		
		protected function handleVerifyProperty(event:Event, passThroughData:Object):void
		{
			//Dict of Mesh2D that contains Polygon2D
			var holder:TestDataHolder = passThroughData.holder;
			var output:Dictionary = passThroughData.output;
			Assert.assertNotNull("Deserialization failed: output", output);
			var meshesCount:int = 0, polygonsCount:int = 0;
			for(var name:String in output)
			{
				var mesh:Mesh2D = output[name];
				Assert.assertNotNull("Deserialization failed: mesh", mesh);
				for(var pName:String in mesh)
				{
					var polygon:Polygon2D = mesh[pName];
					Assert.assertNotNull("Deserialization failed: polygon", polygon);
					Assert.assertNotNull("Deserialization failed: indexes", polygon.indexes);
					Assert.assertEquals("Deserialization failed: indexes", 6, polygon.indexes.length);
					Assert.assertEquals("Deserialization failed: vertices", 4, polygon.numVertices);
					Assert.assertNotNull("Deserialization failed: buffer", polygon.buffer);
					Assert.assertEquals("Deserialization failed: buffer", 64, polygon.buffer.length);
					polygonsCount++;
				}
				meshesCount++;
			}
			Assert.assertEquals( "Deserialization failed: meshes", holder.meshesCount, meshesCount );
			Assert.assertEquals( "Deserialization failed: polygons", holder.polygonsCount, polygonsCount );
		}
	}
}

import com.merlinds.miracle.utils.serializers.DictionarySerializer;

import flash.utils.Endian;

class TestDataHolder
{
	public var data:Object;
	public var meshesCount:int;
	public var polygonsCount:int;
	public var dictSize:int;
	
	
	public function TestDataHolder(data:Object)
	{
		this.data = data;
		meshesCount = data.length;
		for each( var mesh:Object in data )
			polygonsCount += mesh.mesh.length;
		
		dictSize = new DictionarySerializer('us-ascii', Endian.LITTLE_ENDIAN)
				.serializeFromObject(data, false).length;
	}
}