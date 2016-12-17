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
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	
	/**
	 * MTF (Miracle texture format) serializer.
	 * This is the abstract class for provide public API of MTFSerializer.
	 * Do not use constructor of this class to instantiate serializer!
	 * Use factory method <code>createSerializer</code> instead.
	 *
	 * @see MTFSerializer.createSerializer Use for serializer instantiation
	 */
	public class MTFSerializer
	{
		/**
		 * Available protocol version 2.0
		 * Serializer for MTF v 1.0 does not exist, it was JSON, that why versions began from 2.0
		 */
		public static const V2:uint = 0x0002;
		
		/**
		 * Instantiate new serializer
		 * @param version Version of serialize protocol
		 * @return Instance of new serializer
		 * @throws ArgumentError Version is unknown. Use List of available protocols
		 */
		public static function createSerializer(version:uint):MTFSerializer
		{
			var serializerClass:Class;
			switch(version)
			{
				case V2: serializerClass = MTFSerializerV2; break;
				/*
				 Add new version here, in new case body:
				 case [Version number]: serializerClass = [serializer class]; break;
				 */
				default:
					throw new ArgumentError("Unknown version for serializer");
			}
			//No needs for instantiation error checking
			return new serializerClass();
		}
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
		public final function serialize(data:Object):ByteArray
		{
			return executeSerialization(data);
		}
		
		/**
		 * Deserialize <code>ByteArray</code> with MTF to Miracle texture data
		 * @param bytes Bytes for deserialization
		 * @param callback Deserialization complete callback method
		 */
		public final function deserialize(bytes:ByteArray, callback:Function):void
		{
			_callback = callback;
			executeDeserialization(bytes);
		}
		
		/**
		 * @inheritDoc
		 */
		public final function toString():String
		{
			return "MTFSerializer{Protocol version=" + _version + "}";
		}
		//endregion
		
		//region Protected methods
		/**
		 * Abstract method serialization.
		 * @param data Data object than need to be serialized
		 * @return <code>ByteArray</code> of MTF file
		 *
		 * @throws IllegalOperationError Must be overridden as abstract method!
		 */
		[Abstract]
		protected function executeSerialization(data:Object):ByteArray
		{
			throw new IllegalOperationError("Must be overridden as abstract method!");
		}
		
		/**
		 * Abstract method of deserialization
		 * @param bytes Bytes for deserialization
		 *
		 * @throws IllegalOperationError Must be overridden as abstract method!
		 */
		[Abstract]
		protected function executeDeserialization(bytes:ByteArray):void
		{
			throw new IllegalOperationError("Must be overridden as abstract method!");
		}
		
		/**
		 * Must be executed after deserialization complete
		 */
		protected final function deserializationComplete(/*TODO: Add output data fields*/):void
		{
			if(_callback is Function)
			{
				_callback.call(this/*TODO: Send data*/);
			}
			_callback = null;
		}
		//endregion
	}
}
