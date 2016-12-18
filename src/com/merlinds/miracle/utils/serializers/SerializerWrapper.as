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
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	/**
	 * Serializer wrapper, provide access to concrete serializer.
	 * Also auto instantiate serializer by data signature
	 */
	public class SerializerWrapper
	{
		private var _availableSerializers:Dictionary;
		private var _useDefault:Boolean;
		private var _default:uint;
		
		/**
		 * Constructor
		 * @param availableSerializers Dict of available serializers
		 * @param useDefault If true, will be used default serializer instead of throwing error.
		 * @param defaultV Default version of serializer
		 */
		public function SerializerWrapper(availableSerializers:Dictionary, useDefault:Boolean, defaultV:uint)
		{
			_availableSerializers = availableSerializers;
			_useDefault = useDefault;
			_default = defaultV;
		}
		
		/**
		 * Get concrete serializer by protocol version
		 * @param version Version of the protocol
		 * @return Instance of serializer
		 *
		 * @throws ArgumentError Unknown version for serializer if useDefault is false
		 */
		protected final function getSerializerByVersion(version:uint):AbstractSerializer
		{
			var serialize:AbstractSerializer = getSerializer( version );
			if ( serialize == null )
			{
				if ( !_useDefault )
					throw new ArgumentError( "Unknown version for serializer" );
				serialize = _availableSerializers[ _default ];
			}
			return serialize;
		}
		
		/**
		 * Get concrete serializer by signature version
		 * @param bytes Data that will be serialized
		 * @return Instance of serializer
		 *
		 * @throws ArgumentError Unknown version for serializer if useDefault is false
		 */
		protected final function getSerializerBySignature(bytes:ByteArray):AbstractSerializer
		{
			//Get version from signature
			bytes.position = 3;
			bytes.endian = Endian.LITTLE_ENDIAN;
			var version:uint = bytes.readUnsignedInt();
			var serialize:AbstractSerializer = getSerializer( version );
			//try to change endian and search again
			if ( serialize == null )
			{
				bytes.endian = Endian.BIG_ENDIAN;
				version = bytes.readUnsignedInt();
				serialize = getSerializer( version );
			}
			//not found yet
			if ( serialize == null )
			{
				if ( !_useDefault )
					throw new ArgumentError( "Unknown version for serializer" );
				serialize = _availableSerializers[ _default ];
			}
			
			return serialize;
		}
		/**
		 * Get serializer by version
		 * @param version Version of serializer
		 * @return Instance of serializer
		 */
		private final function getSerializer(version:uint):AbstractSerializer
		{
			var serializerClass:Class = _availableSerializers[ version ];
			if ( serializerClass == null )return null;
			return new serializerClass();
		}
		
	}
}
