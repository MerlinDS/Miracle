/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 21:50
 */
package com.merlinds.miracle.utils {
	import flash.utils.ByteArray;

	/**
	 * Asset helper ro Miracle framework
	 */
	public class Asset {
		public static const XML_TYPE:String = "xml";
		public static const MESH_TYPE:String = "json";
		public static const TEXTURE_TYPE:String = "atf";
		/**
		 * Name of the asset that will be used as id in Miracle
		 */
		public var name:String;
		/**
		 * ATF _bytes
		 */
		private var _bytes:ByteArray;

		/** Type of the asset **/
		private var _type:String;

		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Create Asset
		 * @param name Name of the asset that will be used as id in Miracle
		 * @param bytes Asset bytes
		 */
		public function Asset(name:String, bytes:ByteArray) {
			this.name = name;
			_bytes = bytes;
		}

		/** Prepare instance for GC **/
		public function destroy():void {
			_bytes = null;
			_type = null;
			name = null;
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
		public function get type():String {
			if(_type == null){
				_type = AtfData.isAtfData(_bytes) ? TEXTURE_TYPE : MESH_TYPE;
				//check for xml
				if(String.fromCharCode(_bytes[0]) == "<"){
					_type = XML_TYPE;
				}
			}
			return _type;
		}

		public function output():Object {
			var output:Object = _bytes;
			if(this.type != TEXTURE_TYPE){
				output = _bytes.readUTFBytes( _bytes.length );
			}
			if(this.type == MESH_TYPE){
				output = JSON.parse( output as String );
			}else if(this.type == XML_TYPE){
				output = new XML( output as String );
			}
			return output;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
