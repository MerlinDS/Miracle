/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 18:32
 */
package com.merlinds.miracle.format {
	import flash.utils.ByteArray;

	/**
	 * Miracle format File creator
	 */
	public class FormatFile extends ByteArray {
		private var _charSet:String;
		private var _signature:String;
		private var _finalized:Boolean;
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param signature File signature
		 * @param charSet Characters set
		 */
		public function FormatFile(signature:String, charSet:String) {
			_signature = signature;
			_charSet = charSet;
			super();
		}

		public function finalize():void {
			_finalized = true;
		}


		override public function clear():void {
			super.clear();
			_finalized = false;
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
		/** Return flag of finalization.
		 * If flag equals true, file are finalized,
		 * all data was written to bytes and file can be saved to disk as Miracle Format file.
		 * In other case file was not finalized and has no written data.
		 **/
		public function get finalized():Boolean {
			return _finalized;
		}

		public function get charSet():String {
			return _charSet;
		}

		public function get signature():String {
			return _signature;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
