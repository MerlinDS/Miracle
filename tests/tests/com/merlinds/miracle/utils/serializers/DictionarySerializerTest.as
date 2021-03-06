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
	import com.merlinds.miracle.utils.serializers.DictionarySerializer;
	
	import flash.events.Event;
	
	import flash.events.EventDispatcher;
	
	import flash.utils.ByteArray;
	
	import flash.utils.Endian;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	public class DictionarySerializerTest extends EventDispatcher
	{
		private var _serializer:DictionarySerializer;
		private var _aliases:Vector.<String>;
		private var _bytesLength:int;
		
		[Before]
		public function setUp():void
		{
			_serializer = new DictionarySerializer('us-ascii', Endian.LITTLE_ENDIAN);
			_aliases = new <String>[];
			var n:int = 300;
			_aliases.length = n;
			for(var i:int = 0; i < n; ++i)
			{
				_aliases[i] = "test word " + i;
				_bytesLength += _aliases[i].length + 4 /*bytes for length description*/;
			}
			_bytesLength+=4;//Ending bytes
		}
		
		
		[Test(expects="ArgumentError")]
		public function testSerializationError():void
		{
			_serializer.serialize(null);
		}
		
		[Test(expects="ArgumentError", description="Null bytes for deserialization")]
		public function testDeserializationError():void
		{
			_serializer.deserialize(null, null, null);
		}
		
		[Test(expects="ArgumentError", description="bytes length for deserialization")]
		public function testDeserializationLengthError():void
		{
			_serializer.deserialize(new ByteArray(), null, null);
		}
		
		[Test(description="Serialization of aliases to bytes array")]
		public function testSerialization():void
		{
			var bytes:ByteArray = _serializer.serialize(_aliases);
			Assert.assertNotNull("Serialization: bytes", bytes);
			Assert.assertEquals("Serialization: bytes", _bytesLength, bytes.length);
		}
		
		[Test(description="Serialization of object to bytes array")]
		public function testObjectSerialization():void
		{
			var data:Object = {};
			for(var i:int = 0; i < _aliases.length; ++i)
			{
				data[ "field" + i ] = _aliases[i];
			}
			var bytes:ByteArray = _serializer.serializeFromObject(data);
			Assert.assertNotNull("Serialization: bytes", bytes);
			Assert.assertEquals("Serialization: bytes", _bytesLength, bytes.length);
			for(i = 0; i < _aliases.length; ++i)
			{
				Assert.assertTrue("Serialization: object", data["field" + i] is int);
			}
		}
		
		
		[Test(async, description="Deserialization of aliases from bytes array")]
		public function testDeserialization():void
		{
			var bytes:ByteArray = _serializer.serialize(_aliases);
			bytes.position = 0;
			
			var passThroughData:Object = {};
			passThroughData.output = new Vector.<String>();
			
			this.addEventListener( "callback",
					Async.asyncHandler( this, handleVerifyProperty, 100, passThroughData ),
					false, 0, true );
			_serializer.deserialize(bytes, passThroughData.output as Vector.<String>, function ():void
			{
				dispatchEvent( new Event( 'callback' ) );
			} );
			
			
		}
		
		protected function handleVerifyProperty(event:Event, passThroughData:Object):void
		{
			var aliases:Vector.<String> = passThroughData.output as Vector.<String>;
			Assert.assertNotNull("Deserialization: aliases", aliases);
			Assert.assertEquals("Deserialization: aliases", _aliases.length, aliases.length);
			for(var i:int = 0; i < _aliases.length; ++i)
			{
				Assert.assertEquals("Deserialization: alias " + i, _aliases[i], aliases[i]);
			}
		}
	}
}
