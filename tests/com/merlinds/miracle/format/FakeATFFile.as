/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 9:34
 */
package com.merlinds.miracle.format {
	import flash.utils.ByteArray;

	public class FakeATFFile extends ByteArray {

		private static const SIGNATURE:String = "ATF";
		private static const RESERVED:int = 4;//bytes
		private static const VERSION_SIZE:int = 1;//bytes
		private static const LENGTH_SIZE:int = 4;

		private static const HEADER_SIZE:int = SIGNATURE.length + RESERVED
				+ VERSION_SIZE + LENGTH_SIZE;

		private var _version:String;
		private var _size:int;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function FakeATFFile(size:int, version:String = " ") {
			super();
			_version = version;
			_size = size - HEADER_SIZE;
			this.create();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function create():void {
			this.position = 0;
			this.writeUTFBytes(SIGNATURE);
			this.writeUnsignedInt(0x255);//RESERVED
			this.writeUTFBytes(_version);//VERSION
			this.writeInt(_size);//LENGTH
			var n:int = 0;
			while(n++ < _size){
				this.writeByte(4);
			}
			this.position = 0;
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
