/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 21:16
 */
package com.merlinds.miracle {
	import flash.utils.ByteArray;
	import flash.utils.ByteArray;

	public class MeshCollection{
		public var name:String;
		public var meshList:Vector.<Mesh>;
		public var bytes:ByteArray;

		private var _size:int;
		//can be not used
		public var index:int = -1;

		public function MeshCollection(name:String, bytes:ByteArray, data:Array) {
			this.meshList = new <Mesh>[];
			this.bytes = bytes;
			this.name = name;
			//parse data
			var n:int = data.length;
			for(var i:int = 0; i < n; i++){
				this.meshList[i] = new Mesh(data[i]);
			}
		}
		//==============================================================================
		//{region							PUBLIC METHODS
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get size():int {
			if(_size == 0){
				this.bytes.position = 14;//TODO Ask salazkin about this numer
				_size = Math.pow( 2, bytes.readUnsignedByte() );
			}
			return _size;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
