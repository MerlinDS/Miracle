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
		/**
		 * Name of the asset that will be used as id in Miracle
		 */
		public var name:String;
		/**
		 * ATF bytes
		 */
		public var bytes:ByteArray;
		/**
		 * Animation config file
		 */
		public var data:Array;

		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Create Asset
		 * @param name Name of the asset that will be used as id in Miracle
		 * @param bytes ATF bytes
		 * @param data Animation config file
		 */
		public function Asset(name:String, bytes:ByteArray, data:Array) {
			this.name = name;
			this.bytes = bytes;
			this.data = data;
		}

		/** Prepare instance for GC **/
		public function destroy():void {
			this.name = null;
			this.bytes = null;
			this.data = null;
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
