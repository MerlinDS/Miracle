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
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.EmptyFrameInfo;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.geom.Bounds;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.utils.serializers.DictionarySerializer;
	import com.merlinds.miracle.utils.serializers.MSVersions;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * MAF (Miracle animation format) serializer.
	 * Protocol version 2.0
	 *
	 * @inheritDoc
	 */
	internal class MAFSerializerV2 extends AbstractMTASerializer
	{
		private static const BOUNDS_SIZE:int = 16;
		private static const MATRIX_SIZE:int = 68;
		private static const FRAME_SIZE:int = 14;
		//region Properties
		private var _dictSerializer:DictionarySerializer;
		//temp data
		private var _output:Dictionary;
		private var _bytes:ByteArray;
		private var _aliases:Vector.<String>;
		private var _offsets:Vector.<int>;
		private var _time:Number = 0;
		private var _scale:Number;
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
			var position:int = output.position;
			for ( i = 0; i < n; i++ )output.writeInt( 0 );//add place sizes for future writing
			var sizes:Vector.<int> = new <int>[];
			sizes.length = n;
			for ( i = 0; i < n; i++ )
			{
				var chunk:ByteArray = serializeAnimation( data[ i ] );
				sizes[ i ] = chunk.length;
				output.writeBytes( chunk, 0, chunk.length );
			}
			//write offsets to header
			output.position = position;
			position = position + n * 4;
			for ( i = 0; i < n; i++ )
			{
				output.writeInt( position );
				position += sizes[i];
			}
				
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
				output.writeInt( matrices.length );//length of the matrices list
				serializeMatrices( matrices, output );
				output.writeInt( frames.length );//length of the frames list
				serializeFrames( frames, matrices.length, output );
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
				output.writeFloat( matrix.offsetX );
				output.writeFloat( matrix.offsetY );
				output.writeFloat( matrix.tx );
				output.writeFloat( matrix.ty );
				output.writeFloat( matrix.scaleX );
				output.writeFloat( matrix.scaleY );
				output.writeFloat( matrix.skewX );
				output.writeFloat( matrix.skewY );
				//color
				output.writeFloat( color.redMultiplier );
				output.writeFloat( color.greenMultiplier );
				output.writeFloat( color.blueMultiplier );
				output.writeFloat( color.alphaMultiplier );
				output.writeFloat( color.redOffset );
				output.writeFloat( color.greenOffset );
				output.writeFloat( color.blueOffset );
				output.writeFloat( color.alphaOffset );
				output.writeInt( color.type );
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
		 * @param matricesLength
		 * @param output
		 */
		[Inline]
		private final function serializeFrames(data:Array, matricesLength:int, output:ByteArray):void
		{
			for ( var i:int = 0; i < data.length; i++ )
			{
				var frame:Object = data[ i ];
				output.writeBoolean( frame != null );//is null
				if ( frame == null )
				{
					output.position--;
					output.position += FRAME_SIZE;//offset for next frame
					continue;
				}
				
				if(frame.polygonName is String)
					throw new ArgumentError("Aliases broken!");
				
				if(frame.motion && frame.index + 1 >= matricesLength)
				{
					trace("WARNING: invalid motion flag!");
					frame.motion = false;
//					throw new ArgumentError("Index of frame is out of bounds!");
				}
				
				output.writeInt( frame.index );//4
				output.writeBoolean( frame.motion );//1
				output.writeInt( frame.polygonName );//4
				output.writeFloat( frame.t );//4
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
			clearTempData();
			_scale = scale;
			_output = output;
			_bytes = bytes;
			_aliases = new <String>[];
			//deserialize aliases first
			_dictSerializer.deserialize( _bytes, _aliases, function():void{
				var i:int, n:int = _bytes.readInt();
				_offsets = new <int>[];
				for ( i = 0; i < n; ++i )_offsets[ i ] = _bytes.readInt();
				deserializeAnimation();
			} );
		}
				
		private function deserializeAnimation():void
		{
			if(_offsets.length == 0)
			{
				clearTempData();
				deserializationComplete();
				return;
			}
			
			if(_time == 0)_time = getTimer();
			_bytes.position = _offsets.shift();
			var name:String = _aliases[_bytes.readInt()];
			var totalFrames:int = _bytes.readInt();
			var bounds:Bounds = deserializeBounds(_bytes, _scale);
			var numLayers:int = _bytes.readInt();
			//save to output
			var frames:Vector.<FrameInfo> =
					deserializeFrames(_bytes, numLayers, totalFrames, _scale, _aliases);
			var animationHelper:AnimationHelper =
					new AnimationHelper(totalFrames, numLayers, frames);
			animationHelper.bounds = bounds;
			_output[name] = animationHelper;
			//execute next animation deserialization
			if(getTimer() - _time > 10)
			{
				_time = 0;
				setTimeout(deserializeAnimation, 0);
				return;
			}
			deserializeAnimation();
				
		}
		
		
		[Inline]
		private final function deserializeBounds(bytes:ByteArray, scale:Number):Bounds
		{
			return new Bounds(
				bytes.readFloat() * scale,
				bytes.readFloat() * scale,
				bytes.readFloat() * scale,
				bytes.readFloat() * scale
			);
		}
		
		[Inline]
		private final function deserializeFrames(bytes:ByteArray, numLayers:int, totalFrames:int,
												 scale:Number, aliases:Vector.<String>):Vector.<FrameInfo>
		{
			var i:int, j:int, n:int, m:int;
			var index:int, motion:Boolean, t:Number, name:String;
			var matrices:Vector.<Transformation>;
			
			n = numLayers;
			var frames:Vector.<FrameInfo> = new <FrameInfo>[];
			frames.length = n * totalFrames;
			frames.fixed = true;
			//read data
			for (i = 0; i < n; i++)
			{
				//read matrices, and temporary save them
				matrices = new <Transformation>[];
				m = bytes.readInt();
				matrices.length = m;
				for(j = 0; j < m; ++j)
				{
					var matrix:TransformMatrix = new TransformMatrix(
						bytes.readFloat() * scale, bytes.readFloat() * scale,//offset
						bytes.readFloat() * scale, bytes.readFloat() * scale,//tx
						bytes.readFloat(), bytes.readFloat(),//scale
						bytes.readFloat(), bytes.readFloat()//skew
					);
					var color:Color = new Color(
						bytes.readFloat(), bytes.readFloat(), bytes.readFloat(), bytes.readFloat(),
						bytes.readFloat(), bytes.readFloat(), bytes.readFloat(), bytes.readFloat()
					);
					color.type = bytes.readInt();
					matrices[j] = new Transformation(matrix, color);
				}
				//read frames
				m = bytes.readInt();
				for(j = 0; j < m; ++j)
				{
					motion = false;
					if(!bytes.readBoolean())//frame is null
					{
						bytes.position--;
						bytes.position += FRAME_SIZE;//offset for next frame
						frames[totalFrames * i + j] = EmptyFrameInfo.getConst();
						continue;
					}
					//read
					index = bytes.readInt();
					motion = bytes.readBoolean();
					name = aliases[bytes.readInt()];
					t = bytes.readFloat();
					//save
					frames[totalFrames * i + j] = new FrameInfo(name, matrices[index],
							motion ? matrices[index + 1] : null, t);
				}
				//fill empty frames
				j = totalFrames - (totalFrames - m);//calculate delta
				for(; j < totalFrames; ++j)
				{
					if(frames[totalFrames * i + j] == null)
						frames[totalFrames * i + j] = EmptyFrameInfo.getConst();
				}
				//clear temp data
				matrices.length = 0;
				
			}
			return frames;
		}
		
		private function clearTempData():void
		{
			_output = null;
			_bytes = null;
			_aliases = null;
			_offsets = null;
			_time = 0;
			_scale = 1;
		}
	}
}
