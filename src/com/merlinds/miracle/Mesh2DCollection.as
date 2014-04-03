/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 21:16
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.utils.AtfData;

	import flash.utils.ByteArray;

	public class Mesh2DCollection{
		/** Name of the mesh collection**/
		public var name:String;
		public var meshList:Vector.<Mesh2D>;
		public var bytes:ByteArray;
		//linked texture parameters
		/**
		 *  Format of the texture linked to current mesh collection.
		 *  @default flash.display3D.Context3DTextureFormat.BGRA
		 **/
		public var textureFormat:String;
		/** Width of the texture linked to current mesh collection.**/
		public var textureWidth:int;
		/** Height of the texture linked to current mesh collection.**/
		public var textureHeight:int;
		/** Num  of the texture in ATF linked to current mesh collection.**/
		public var textureNum:int;
		//can be not used
		public var index:int = -1;

		public function Mesh2DCollection(name:String, bytes:ByteArray, data:Array) {
			this.meshList = new <Mesh2D>[];
			this.bytes = bytes;
			this.name = name;
			//parse data
			var n:int = data.length;
			for(var i:int = 0; i < n; i++){
				this.meshList[i] = new Mesh2D(data[i]);
			}
			//get atf data, and validate format of the bytes
			AtfData.getAtfParameters(bytes, this);
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}
