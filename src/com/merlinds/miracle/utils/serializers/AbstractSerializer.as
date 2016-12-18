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
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Abstract class for all serializers
	 */
	public class AbstractSerializer
	{
		//region Properties
		private var _version:int;
		private var _signature:String;
		
		private var _endian:String;
		private var _signatureBytes:ByteArray;
		//endregion
		
		public function AbstractSerializer(signature:String, version:uint, endian:String = Endian.LITTLE_ENDIAN)
		{
			_version = version;
			_signature = signature;
			_endian = endian;
			//Create signature and version header
			_signatureBytes = new ByteArray();
			_signatureBytes.endian = _endian;
			_signatureBytes.writeUTFBytes( signature );
			_signatureBytes.writeUnsignedInt( _version );
		}
		
		/**
		 * Create new byte array with special format signature
		 * @param version Version of the protocol
		 * @return Instance of new <code>ByteArray</code> with special signature in it
		 */
		protected function createByteArray(version:uint):ByteArray
		{
			if ( version != version )
				throw new ArgumentError( "Version does not equals!" );
			//Create output byteArray and fill it with signature
			var output:ByteArray = new ByteArray();
			output.endian = endian;
			output.writeBytes( signatureBytes );
			//provide little offset
			output.writeByte( 0 );
			return output;
		}
		
		/**
		 * Check validity of signature in bytes
		 * @param bytes <code>ByteArray</code> that need to be validated
		 */
		protected function validateSignature(bytes:ByteArray):void
		{
			//Check signature
			bytes.position = 0;
			bytes.endian = endian;
			var signature:String = String.fromCharCode( bytes[ 0 ], bytes[ 1 ], bytes[ 2 ] );
			if ( signature != _signature )
				throw new IOError( "Bad format signature" );
			bytes.position = 3;
			var version:uint = bytes.readUnsignedInt();
			if ( version != version )
				throw new IOError( "Bad format version" );
			//signature verified
			//provide little offset
			bytes.position += 1;
		}
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
		
		[Inline]
		public final function get version():int
		{
			return _version;
		}
		
		[Inline]
		public final function get signature():String
		{
			return _signature;
		}

//endregion
	}
}
