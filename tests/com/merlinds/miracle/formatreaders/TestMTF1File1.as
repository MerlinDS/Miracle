/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:11
 */
package com.merlinds.miracle.formatreaders {
	import flash.utils.ByteArray;

	public class TestMTF1File1 extends ByteArray{

		private var _charSet:String;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function TestMTF1File1(charSet:String) {
			_charSet = charSet;
		}

		public function writeMTF1Header():void {
			this.clear();
			this.position = 0;
			//write signature
			this.writeMultiByte(Signatures.MTF1, _charSet);
			//write header
			this.writeShort(4);//float type
			this.writeShort(4);//float type
			this.writeShort(4);//float type
			this.writeMultiByte("ATF", _charSet);
			this.position = TextureHeadersFormat.DATE;
			this.writeInt(new Date().getTime());
			//write linkers block
//			var testData:Object = {
//				vertices:[1,2,3,4,5,6,7,8],
//				uv:[1,2,3,4,5,6,7,8],
//				indexes:[1,2,3,4,5,6]
//			};
		}

		public function writeAnimationName(name:String):void
		{
			//write header
			this.writeByte(ControlCharacters.GS);
			//write block length
			this.writeShort(name.length);
			this.writeMultiByte(name, _charSet);
		}

		public function writeAnimationPartName(name:String):void
		{
			//write header
			this.writeByte(ControlCharacters.RS);
			//write block length
			this.writeShort(name.length);
			this.writeMultiByte(name, _charSet);
		}

		public function writeAnimationSizes(points:int, indexes:int):void
		{
			//write header
			this.writeByte(ControlCharacters.US);
			this.writeShort(points);
			this.writeShort(indexes);
		}

		public function writeDataEscape():void {
			this.writeByte(ControlCharacters.DLE);
		}

		public function writeShortArray(...args):void {
			for(var i:int = 0; i < args.length; i++){
				this.writeShort(args[i]);
			}
		}

		public function writeFloatArray(...args):void {
			for(var i:int = 0; i < args.length; i++){
				this.writeFloat(args[i]);
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS

		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
