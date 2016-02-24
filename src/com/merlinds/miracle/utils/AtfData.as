/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 19:37
 */
package com.merlinds.miracle.utils {
	import flash.display3D.Context3DTextureFormat;
	import flash.utils.ByteArray;

	/**
	 * Atf format parser. Base on Starling Framework code
	 */
	public class AtfData {

		private static const VERSION_POSITION:int = 6;
		private static const NEW_VERSION:int = 255;
		private static const NEW_POSITION:int = 12;
		private static const OLD_POSITION:int = 6;

		public function AtfData() {
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public static function getAtfParameters(data:ByteArray, result:Object = null):Object {
			if (!isAtfData(data)) throw new ArgumentError("Invalid ATF data");
			//create result format
			if(result == null){
				result = {
					format:"",
					width:0,
					height:0,
					num:0
				};
			}

			if (data[VERSION_POSITION] == NEW_VERSION){
				// new file version
				data.position = NEW_POSITION;
			} else {
				data.position =  OLD_POSITION; // old file version
			}

			switch (data.readUnsignedByte())
			{
				case 0: case 1: result.format = Context3DTextureFormat.BGRA; break;
				case 2: case 3: result.format = Context3DTextureFormat.COMPRESSED; break;
				// explicit string to stay compatible
				case 4: case 5: result.format = Context3DTextureFormat.COMPRESSED_ALPHA; break;
				// with older versions
				default: throw new Error("Invalid ATF format");
			}

			result.width = Math.pow(2, data.readUnsignedByte());
			result.height = Math.pow(2, data.readUnsignedByte());
			result.num = data.readUnsignedByte();

			// version 2 of the new file format contains information about
			// the "-e" and "-n" parameters of png2atf

			if (data[5] != 0 && data[6] == 255)
			{
				var emptyMipmaps:Boolean = (data[5] & 0x01) == 1;
				var numTextures:int  = data[5] >> 1 & 0x7f;
				result.num = emptyMipmaps ? 1 : numTextures;
			}

			return result;
		}

		public static function isAtfData(data:ByteArray):Boolean
		{
			if (data.length < 3) return false;
			else
			{
				var signature:String = String.fromCharCode(data[0], data[1], data[2]);
				return signature == "ATF";
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
