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
	import flash.errors.IOError;
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import org.hamcrest.core.throws;
	
	/**
	 * MTF (Miracle texture format) serializer.
	 * This is the abstract class for MTFSerializer.
	 * Do not use constructor of this class to instantiate serializer!
	 * Use factory method <code>createSerializer</code> instead.
	 *
	 * @see AbstractMTFSerializer.createSerializer Use for serializer instantiation
	 */
	internal class AbstractMTFSerializer implements IMTFSerializer
	{
		/**
		 * Miracle texture format signature
		 */
		public static const SIGNATURE:String = "MTF";
		
		//region Properties
		private var _version:int;
		private var _callback:Function;
		
		private var _endian:String;
		private var _signatureBytes:ByteArray;
		//endregion
		/**
		 * Constructor
		 * @param version of serialization protocol
		 * @param endian Bytes endian
		 */
		public function AbstractMTFSerializer(version:uint, endian:String = Endian.LITTLE_ENDIAN)
		{
			_version = version;
			_endian = endian;
			//Create signature and version header
			_signatureBytes = new ByteArray();
			_signatureBytes.endian = _endian;
			_signatureBytes.writeUTFBytes( SIGNATURE );
			_signatureBytes.writeUnsignedInt( _version );
		}
		
		//region Public
		/**
		 * @inheritDoc
		 */
		public final function serialize(data:Object, version:uint):ByteArray
		{
			if ( version != _version )
				throw new ArgumentError( "Version does not equals!" );
			//Create output byteArray and fill it with signature
			var output:ByteArray = new ByteArray();
			output.endian = _endian;
			output.writeBytes( _signatureBytes );
			//provide little offset
			output.writeByte( 0 );
			//Send data and output to serialization
			executeSerialization( data, output );
			//Verify and return output
			if ( output.length < 4 )
				throw new RangeError( "Output length less than 4 bytes. Byte array is corrupted!" );
			return output;
		}
		
		/**
		 * @inheritDoc
		 */
		public final function deserialize(bytes:ByteArray, output:Dictionary,
										  scale:Number, alias:String,
										  callback:Function):void
		{
			_callback = callback;
			//Check signature
			bytes.position = 0;
			bytes.endian = _endian;
			var signature:String = String.fromCharCode( bytes[ 0 ], bytes[ 1 ], bytes[ 2 ] );
			if ( signature != SIGNATURE )
				throw new IOError( "Bad format signature" );
			bytes.position = 3;
			var version:uint = bytes.readUnsignedInt();
			if ( version != _version )
				throw new IOError( "Bad format version" );
			//signature verified
			//provide little offset
			bytes.position += 1;
			executeDeserialization( bytes, output, scale, alias );
		}
		
		/**
		 * @inheritDoc
		 */
		public final function toString():String
		{
			return "AbstractMTFSerializer{Protocol version=" + _version + "}";
		}
		
		//endregion
		
		//region Protected methods
		/**
		 * Abstract method serialization.
		 * @param data Data object than need to be serialized
		 * @param output Output <code>ByteArray</code> of MTF file
		 *
		 * @throws IllegalOperationError Must be overridden as abstract method!
		 */
		[Abstract]
		protected function executeSerialization(data:Object, output:ByteArray):void
		{
			throw new IllegalOperationError( "Must be overridden as abstract method!" );
		}
		
		/**
		 * Abstract method of deserialization
		 * @param bytes Bytes for deserialization
		 *
		 * @param output Output dictionary
		 * @param scale Global scene scale (need for Polygon building)
		 * @param alias Texture alias for meshes
		 * @throws IllegalOperationError Must be overridden as abstract method!
		 */
		[Abstract]
		protected function executeDeserialization(bytes:ByteArray, output:Dictionary, scale:Number, alias:String):void
		{
			throw new IllegalOperationError( "Must be overridden as abstract method!" );
		}
		
		/**
		 * Must be executed after deserialization complete
		 */
		protected final function deserializationComplete(/*TODO: Add output data fields*/):void
		{
			if ( _callback is Function )
			{
				_callback.call( this/*TODO: Send data*/ );
			}
			_callback = null;
		}
		
		//endregion
		
		//region Getters|Setters
		/**
		 * Signature bytes
		 */
		[Inline]
		public final function get signatureBytes():ByteArray
		{
			return _signatureBytes;
		}
		
		/**
		 * Bytes endian that using for serialization
		 */
		[Inline]
		public final function get endian():String
		{
			return _endian;
		}
		
		//endregion
	}
}
