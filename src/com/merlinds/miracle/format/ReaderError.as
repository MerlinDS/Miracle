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
			"MTF file bytes equals null",
			"MTF file size is to small",
			"Can't read file with current signature. Bad file signature",
			"Bad MTF file structure",
			"Bad texture format",
			"Bad reader format, has no reading methods",
			"Bad animation header",
			"Bad layer header",
			"Bad polygon index. Can not find polygon in temporary list",
			"Bad transformation index. Can not find transformation in temporary list"
		];

		public static const UNKNOWN_ERROR:int = 0;
		public static const FILE_IS_NULL:int = 1;
		public static const BAD_FILE_SIZE:int = 2;
		public static const BAD_FILE_SIGNATURE:int = 3;
		public static const BAD_FILE_STRUCTURE:int = 4;
		public static const BAD_TEXTURE_FORMAT:int = 5;
		public static const BAD_READER_FORMAT:int = 6;
		public static const BAD_ANIMATION_HEADER:int = 7;
		public static const BAD_LAYER_HEADER:int = 8;
		public static const BAD_POLYGON_INDEX:int = 9;
		public static const BAD_TRANSFORM_INDEX:int = 10;

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
