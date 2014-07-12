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
		public static const XML_TYPE:String = "XML";
		/** TimeLine Animation **/
		public static const TIMELINE_TYPE:String = "TLA";
		public static const MESH_TYPE:String = "MSH";
		public static const TEXTURE_TYPE:String = "ATF";
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
			this.name = name.substr( 0, name.lastIndexOf(".") );
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
		private function getSignature():String {
			return _bytes.length < 3 ? null : String.fromCharCode(_bytes[0], _bytes[1], _bytes[2]);
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get type():String {
			if(_type == null){
				var signature:String = this.getSignature();
				switch (signature){
					case TEXTURE_TYPE : _type = TEXTURE_TYPE; break;
					case "MSH" :{
						_type = MESH_TYPE;
						//cut signature from mesh
						var bytes:ByteArray = new ByteArray();
						_bytes.position = 3;
						_bytes.readBytes(bytes, 0, _bytes.length - 3);
						_bytes.clear();
						_bytes = bytes;
						break;
					}
					default :{
						if(String.fromCharCode(_bytes[0]) == "<"){
							_type = XML_TYPE;
						}else{
							_type = TIMELINE_TYPE;
						}
					}
				}
			}
			return _type;
		}

		public function get output():* {
			var output:Object = _bytes;
			if(this.type != TEXTURE_TYPE){
				output = _bytes.readUTFBytes( _bytes.length );
			}
			if(this.type == MESH_TYPE || this.type == TIMELINE_TYPE){
				output = JSON.parse( output as String );
				output = output.data;
			}else if(this.type == XML_TYPE){
				output = new XML( output as String );
			}
			return output;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
