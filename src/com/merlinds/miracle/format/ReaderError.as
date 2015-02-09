/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 14:33
 */
package com.merlinds.miracle.format {
	public class ReaderError {

		private static const _ERROR_ID_PREFIX:int = 9000;
		private static const _ERROR_MESSAGES:Vector.<String> = new <String>[
			"Unknown error",
			"Can't read file with current signature. Bad file signature",
			"Bad MTF file structure",
			"Bad texture format"
		];

		public static const UNKNOWN_ERROR:int = 0;
		public static const BAD_FILE_SIGNATURE:int = 1;
		public static const BAD_FILE_STRUCTURE:int = 2;
		public static const BAD_TEXTURE_FORMAT:int = 3;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function ReaderError() {
		}

		public static function castError(errorId:int):Error{
			if(errorId >= _ERROR_MESSAGES.length)errorId = UNKNOWN_ERROR;
			return new Error(_ERROR_MESSAGES[errorId], _ERROR_ID_PREFIX + errorId);
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
