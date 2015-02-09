/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 9:33
 */
package com.merlinds.miracle.format {
	import flash.errors.IllegalOperationError;

	/**
	 * Contained constants with available signatures of the format files
	 */
	internal class Signatures {

		/** Size of the signature in bytes **/
		public static const SIZE:int = 4;
		/** Miracle texture format Version 1 **/
		public static const MTF1:String = "MFT1";
		/** Miracle animation format Version 1 **/
		public static const MAF1:String = "MAT1";
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor.
		 * @throw flash.errors.IllegalOperationError Object of this class can not be implemented
		 */
		public function Signatures() {
			throw new IllegalOperationError("Object of this class can not be implemented");
		}
		//} endregion PUBLIC METHODS ===================================================

	}
}
