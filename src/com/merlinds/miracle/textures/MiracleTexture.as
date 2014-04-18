/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:33
 */
package com.merlinds.miracle.textures {
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	public class MiracleTexture {

		private var _bytes:ByteArray;
		/**
		 *  Format of the texture.
		 *  @default flash.display3D.Context3DTextureFormat.BGRA
		 **/
		public var format:String;
		/** Width of the texture.**/
		public var width:int;
		/** Height of the texture.**/
		public var height:int;
		/** Num  of the texture in ATF.**/
		public var num:int;
		public var inUse:Boolean;

		public var texture:Texture;

		public function MiracleTexture(bytes:ByteArray) {
			_bytes = bytes;
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function destroy():void{
			this.texture.dispose();
			this.texture = null;
			this.format = null;
			this.width = 0;
			this.height = 0;
			this.num = 0;
			this.inUse = false;
			_bytes.clear();
			_bytes = null;
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
