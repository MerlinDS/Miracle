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
			this.create();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function create():void {
			this.position = 0;
			this.writeMultiByte(Signatures.MTF1, _charSet);
			this.writeShort(2);
			this.writeShort(2);
			this.writeShort(2);
			this.writeMultiByte("ATF", _charSet);
			this.position = TextureHeadersFormat.DATE;
			this.writeInt(new Date().getTime());
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
