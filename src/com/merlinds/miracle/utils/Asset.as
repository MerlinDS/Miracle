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
		/** TimeLine Animation **/
		public static const TIMELINE_TYPE:String = "MAF";/** Miracle animation format **/
		public static const TEXTURE_TYPE:String = "MTF";/** Miracle texture format **/
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

		public function toString():String {
			return "[Asset(name = " + this.name + ", type = " + this.type + ")]";
		}

		/** Prepare instance for GC **/
		public function destroy():void {
			_bytes = null;
			_type = null;
			this.name = null;
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
					case TIMELINE_TYPE : _type = TIMELINE_TYPE; break;
					default :{}
				}
			}
			return _type;
		}

		public function get output():* {
			if(this.type != TEXTURE_TYPE && this.type != TIMELINE_TYPE){
				throw new ArgumentError("Unknown asset format. Need to use " + TEXTURE_TYPE + " or " + TIMELINE_TYPE +" formats");
			}
			return _bytes;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
