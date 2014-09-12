/**
 * User: MerlinDS
 * Date: 11.09.2014
 * Time: 18:10
 */
package com.merlinds.miracle.meshes {
	/**
	 * The Color class contains information about color transformations, as brightness, alpha and tint.
	 * Information will be used by shader to calculate new color.< br/>
	 *
	 * Color transformation formula for shader (All channels):
	 * <code> resultColor = (colorMultiplier * colorOffset - colorMultiplier * sourceColor) + sourceColor </code>
	 */
	public class Color{
		//constants Types of the Color transformations
		public static const NONE:uint = 0;
		public static const COLOR:int = 1;
		public static const ALPHA:int = 1 << 1;
		//offsets
		/**
		 * A number from -1 to 1 that is added to the red channel value
		 * after it has been multiplied by the redMultiplier value.
		 * @default 0
		 **/
		public var redOffset:Number;
		/**
		 * A number from -1 to 1 that is added to the green channel value
		 * after it has been multiplied by the greenMultiplier value.
		 * @default 0
		 **/
		public var greenOffset:Number;
		/**
		 * A number from -1 to 1 that is added to the blue channel value
		 * after it has been multiplied by the blueMultiplier value.
		 * @default 0
		 **/
		public var blueOffset:Number;
		/**
		 * A number from -1 to 1 that is added to the alpha channel value
		 * after it has been multiplied by the alphaMultiplier value.
		 * @default 0
		 **/
		public var alphaOffset:Number;
		//multipliers
		/**
		 * A decimal value that is multiplied with the red channel value.
		 * @default 0
		 */
		public var redMultiplier:Number;
		/**
		 * A decimal value that is multiplied with the green channel value.
		 * @default 0
		 */
		public var greenMultiplier:Number;
		/**
		 * A decimal value that is multiplied with the blue channel value.
		 * @default 0
		 */
		public var blueMultiplier:Number;
		/**
		 * A decimal value that is multiplied with the alpha channel value.
		 * @default 0
		 */
		public var alphaMultiplier:Number;
		/**
		 * Color transformation type. Has 4 available values:
		 * <ul>
		 *     <li>NONE(0) - no color transformations. Color object will be ignored by Miracle engine</li>
		 *     <li>COLOR(1) - only color transformation channels will be calculated</li>
		 *     <li>ALPHA(1 << 1) - only alpha transformation channel will be calculated</li>
		 *     <li>COLOR + ALPHA - all channels will be calculated</li>
	     * </ul>
		 * <br />
		 * Type doesn't clear parameters, but ignore them on calculation phase.
		 * @default NONE
		 *
		 * @see com.merlinds.miracle.Scene.#calculateMatrix() calculateMatrix method
		 */
		public var type:int;
		//==============================================================================
		//{region							PUBLIC METHODS

		/**
		 * @param redMultiplier The value for the red multiplier, in the range from -1 to 1.
		 * @param greenMultiplier The value for the green multiplier, in the range from -1 to 1.
		 * @param blueMultiplier The value for the blue multiplier, in the range from -1 to 1.
		 * @param alphaMultiplier The value for the alpha transparency multiplier, in the range from -1 to 1.
		 *
		 * @param redOffset The offset value for the red color channel, in the range from -1 to 1.
		 * @param greenOffset The offset value for the green color channel, in the range from -1 to 1.
		 * @param blueOffset The offset value for the blue color channel, in the range from -1 to 1.
		 * @param alphaOffset The offset value for the alpha color channel, in the range from -1 to 1.
		 */
		public function Color(redMultiplier:Number = 0.0, greenMultiplier:Number = 0.0,
		                      blueMultiplier:Number = 0.0, alphaMultiplier:Number = 0.0,
		                      redOffset:Number = 0.0, greenOffset:Number = 0.0,
		                      blueOffset:Number = 0.0, alphaOffset:Number = 0.0) {
			//set multipliers
			this.redMultiplier = redMultiplier;
			this.greenMultiplier = greenMultiplier;
			this.blueMultiplier = blueMultiplier;
			this.alphaMultiplier = alphaMultiplier;
			//set offsets
			this.redOffset = redOffset;
			this.greenOffset = greenOffset;
			this.blueOffset = blueOffset;
			this.alphaOffset = alphaOffset;
			this.type = NONE;
		}

		/**
		 * Formats and returns a string that describes all of the properties of the Color object.
		 * @return A string that lists all of the properties of the Color object.
		 */
		public function toString():String{
			return "[object Color(" +
					"redMultiplier = " + this.redMultiplier + ", greenMultiplier = " + this.greenMultiplier + ", " +
					"blueMultiplier = " + this.blueMultiplier + ", alphaMultiplier = " + this.alphaMultiplier + ", " +
					"redOffset = " + this.redOffset * 255 + ", greenOffset = " + this.greenOffset * 255 + ", " +
					"blueOffset = " + this.blueOffset * 255 + ", alphaOffset = " + this.alphaOffset * 255 + "" +
					")]"
		}

		/**
		 * Create Color from not serialized object
		 * @param object Object that contains data about color
		 * @return Color object serialized instance
		 */
		public static function fromObject(object:Object):Color {
			var color:Color = new Color(
					object.redMultiplier, object.greenMultiplier, object.blueMultiplier, object.alphaMultiplier,
					object.redOffset, object.greenOffset, object.blueOffset, object.alphaOffset
			);
			color.type = object.type;
			return color;

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
