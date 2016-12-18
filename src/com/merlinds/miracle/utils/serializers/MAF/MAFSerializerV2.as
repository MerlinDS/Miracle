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

package com.merlinds.miracle.utils.serializers.MAF
{
	import com.merlinds.miracle.utils.serializers.DictionarySerializer;
	import com.merlinds.miracle.utils.serializers.MSVersions;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	/**
	 * MAF (Miracle animation format) serializer.
	 * Protocol version 2.0
	 *
	 * @inheritDoc
	 */
	internal class MAFSerializerV2 extends AbstractMTASerializer
	{
		private static const BOUNDS_SIZE:int = 16;
		private static const MATRIX_SIZE:int = 72;
		private static const FRAME_SIZE:int = 14;
		//region Properties
		private var _dictSerializer:DictionarySerializer;
		//endregion
		
		public function MAFSerializerV2()
		{
			super( MSVersions.MAF2, Endian.LITTLE_ENDIAN );
			_dictSerializer = new DictionarySerializer( 'us-ascii', endian );
		}
		
		/**
		 * @param data
		 * @param output
		 */
		override protected function executeSerialization(data:Object, output:ByteArray):void
		{
			var aliases:ByteArray = _dictSerializer.serializeFromObject( data );
			output.writeBytes( aliases, 0, aliases.length );
			//map on animations
			var i:int, n:int = data.length;
			output.writeInt( n );//total count of animations
			var sizesPosition:int = output.position;
			for ( i = 0; i < n; i++ )output.writeInt( 0 );//add place sizes for future writing
			var sizes:Vector.<int> = new <int>[];
			sizes.length = n;
			for ( i = 0; i < n; i++ )
			{
				var chunk:ByteArray = serializeAnimation( data[ i ] );
				sizes[ i ] = chunk.length;
				output.writeBytes( chunk, 0, chunk.length );
			}
			//write size to header
			output.position = sizesPosition;
			for ( i = 0; i < n; i++ )
				output.writeInt( sizes[ i ] );
		}
		
		/**
		 * Write animation chunk to output and return size of chunk
		 * @param data Animation object
		 * @return Animation chunk
		 */
		private function serializeAnimation(data:Object):ByteArray
		{
			var output:ByteArray = new ByteArray();
			output.endian = endian;
			output.writeInt( data.name );//name
			output.writeInt( data.totalFrames );//totalFrames
			serializeBounds( data.bounds, output );//bounds
			var layers:Array = data.layers;
			var i:int, n:int = layers.length;
			output.writeInt( n );//Layers count
			for ( i = 0; i < n; i++ )
			{
				var frames:Array = layers[ i ].framesList;
				var matrices:Array = layers[ i ].matrixList;
				output.writeInt( frames.length );//length of the frames list
				serializeMatrices( matrices, output );
				output.writeInt( matrices.length );//length of the matrices list
				serializeFrames( frames, output );
			}
			return output;
		}
		
		/**
		 * Serialize bounds of animation
		 * @param data Bounds object
		 * @example
		 * "bounds": {
		 *		"width": 346.75,
		 *		"height": 352.75,
		 *		"x": -193.65,
		 *		"y": -342.3
		 *	  },
		 * @param output
		 */
		[Inline]
		private final function serializeBounds(data:Object, output:ByteArray):void
		{
			output.writeFloat( data.x );
			output.writeFloat( data.y );
			output.writeFloat( data.width );
			output.writeFloat( data.height );
			//result length 4 * 4 = 16 bytes
		}
		
		/**
		 * Serialize list of matrices to bytes
		 * @param data List of matrices
		 *
		 * @example
		 *
		 * {
         *     "color": {
         *       "blueOffset": 0,
         *       "blueMultiplier": 0,
         *       "greenMultiplier": 0,
         *       "redMultiplier": 0,
         *       "alphaMultiplier": 0.859375,
         *       "alphaOffset": 0,
         *       "type": 2,
         *       "redOffset": 0,
         *       "greenOffset": 0
         *     },
         *     "matrix": {
         *       "skewY": 0,
         *       "offsetY": 0,
         *       "scaleY": 1,
         *       "offsetX": -0.2,
         *       "ty": -3.05,
         *       "scaleX": 1.28933715820313,
         *       "tx": 0.6078674316406261,
         *       "flipX": 1,
         *       "skewX": 0
         *     },
         *     "bounds": null
         * }
		 *
		 * @param output
		 */
		[Inline]
		private final function serializeMatrices(data:Array, output:ByteArray):void
		{
			for ( var i:int = 0; i < data.length; i++ )
			{
				var matrix:Object = data[ i ].matrix;
				var color:Object = data[ i ].color;
				//matrix
				output.writeFloat( matrix.tx );
				output.writeFloat( matrix.ty );
				output.writeFloat( matrix.offsetX );
				output.writeFloat( matrix.offsetY );
				output.writeFloat( matrix.scaleX );
				output.writeFloat( matrix.scaleY );
				output.writeFloat( matrix.skewY );
				output.writeFloat( matrix.skewY );
				output.writeInt( matrix.flipX );
				//color
				output.writeInt( color.type );
				output.writeFloat( color.redOffset );
				output.writeFloat( color.redMultiplier );
				output.writeFloat( color.greenOffset );
				output.writeFloat( color.greenMultiplier );
				output.writeFloat( color.blueOffset );
				output.writeFloat( color.blueMultiplier );
				output.writeFloat( color.alphaOffset );
				output.writeFloat( color.alphaMultiplier );
			}
			//result length 4 * 18 = 72 bytes
		}
		
		/**
		 * Serialize list of frames to bytes
		 * @param data List of frames
		 * @example
		 *
		 * {
         *     "motion": false,
         *     "t": 0,
         *     "index": 11,
         *     "polygonName": "leg_1"
         *   }
		 *
		 * @param output
		 */
		[Inline]
		private final function serializeFrames(data:Array, output:ByteArray):void
		{
			for ( var i:int = 0; i < data.length; i++ )
			{
				var frame:Object = data[ i ];
				output.writeBoolean( frame != null );//is null
				if ( frame == null )
				{
					output.position += 13;//offset for next frame
					continue;
				}
				output.writeBoolean( data.motion );//1
				output.writeFloat( data.t );//4
				output.writeInt( data.index );//4
				output.writeInt( data.name );//4
			}
		}
		
		/**
		 *
		 * @param bytes
		 * @param output
		 * @param scale
		 * @param alias
		 */
		override protected function executeDeserialization(bytes:ByteArray, output:Dictionary, scale:Number, alias:String):void
		{
			
		}
	}
}
