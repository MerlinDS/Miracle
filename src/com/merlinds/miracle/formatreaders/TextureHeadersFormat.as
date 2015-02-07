/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 9:29
 */
package com.merlinds.miracle.formatreaders {
	import flash.errors.IllegalOperationError;

	/**
	 * Contained constants with header format
	 */
	internal class TextureHeadersFormat {

		//Data types
		/** Position of descriptor of vertices elements size (2 bytes)**/
		public static const VT:int = 4;
		/** Position of descriptor of UVs elements size (2 bytes)**/
		public static const UVT:int = 6;
		/** Position of descriptor of indexes elements size (2 bytes)**/
		public static const IT:int = 8;
		//Other descriptors
		/** Position of descriptor of texture format (4 bytes)**/
		public static const TEXTURE_FORMAT:int = 10;
		/** Position of descriptor of modification date (4 bytes)**/
		public static const DATE:int = 14;
		/**Size of the header in bytes **/
		public static const HEADER_SIZE:int = DATE + 4;//Last pointer + pointer size

		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor.
		 * @throw flash.errors.IllegalOperationError Object of this class can not be implemented
		 */
		public function TextureHeadersFormat() {
			throw new IllegalOperationError("Object of this class can not be implemented");
		}
		//} endregion PUBLIC METHODS ===================================================
	}
}
