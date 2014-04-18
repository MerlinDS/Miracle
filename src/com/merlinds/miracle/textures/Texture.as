/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:33
 */
package com.merlinds.miracle.textures {
	import flash.utils.ByteArray;

	public class Texture {

		/**
		 *  Format of the texture linked to current mesh collection.
		 *  @default flash.display3D.Context3DTextureFormat.BGRA
		 **/
		public var format:String;
		/** Width of the texture linked to current mesh collection.**/
		public var width:int;
		/** Height of the texture linked to current mesh collection.**/
		public var height:int;
		/** Num  of the texture in ATF linked to current mesh collection.**/
		public var num:int;

		private var _bytes:ByteArray;

		public function Texture(bytes:ByteArray) {
			_bytes = bytes;
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
