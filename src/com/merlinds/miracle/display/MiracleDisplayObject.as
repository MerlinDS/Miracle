/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 20:56
 */
package com.merlinds.miracle.display
{

	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.events.MiracleEvent;
	import com.merlinds.miracle.geom.Bounds;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.miracle_internal;

	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 * Will be dispatched when instance was added to stage.
	 * If mesh or animation was changed will be dispatched again after drawing on stage with new parameters
	 */
	[Event(type="com.merlinds.miracle.events.MiracleEvent", name="addedToStage")]
	/**
	 * Will be dispatched when instance was removed from stage.
	 * If mesh or animation was changed will be dispatched to
	 */
	[Event(type="com.merlinds.miracle.events.MiracleEvent", name="removedFromStage")]
	public class MiracleDisplayObject extends EventDispatcher
	{
		public static const DELIMITER:String = ".";

		use namespace miracle_internal;

		private var _onStage:Boolean;
		private var _visible:Boolean;
		internal var _isAnimated:Boolean;
		private var _mouseEnable:Boolean;
		private var _demandAnimationInstance:Boolean;

		private var _currentFrame:int;
		public var z:Number;

		private var _mesh:String;
		private var _animation:String;
		private var _animationId:String;
		//Transformations
		public var transformation:Transformation;
		private var _animationInstance:AnimationHelper;

		public function MiracleDisplayObject()
		{
			this.transformation = new Transformation(new TransformMatrix(),
					new Color(), Bounds.getInstance());
			_currentFrame = 0;
			_visible = true;
			this.z = 0;
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		[Inline]
		public final function hitTest(point:Point):Boolean
		{
			if (!_mouseEnable)return false;
			return this.transformation.bounds.containsPoint(point.x, point.y,
				this.transformation.matrix.tx, this.transformation.matrix.ty);
		}

		/**
		 * move instance to new coordinates
		 * @param x
		 * @param y
		 * @param z
		 * @return Current instance
		 */
		public function moveTO(x:Number = 0, y:Number = 0, z:Number = 0):MiracleDisplayObject
		{
			this.transformation.matrix.tx = x;
			this.transformation.matrix.ty = y;
			this.z = z;
			return this;
		}

		miracle_internal function drawn():void
		{
			if (!_onStage)
			{
				//After first draw dispatch event that display object was added to stage
				if (this.hasEventListener(MiracleEvent.ADDED_TO_STAGE))
				{
					this.dispatchEvent(new MiracleEvent(MiracleEvent.ADDED_TO_STAGE));
				}
				_onStage = true;
				this.afterDraw();
			}
		}

		miracle_internal function remove():void
		{
			if (_onStage)
			{
				if (this.hasEventListener(MiracleEvent.REMOVED_FROM_STAGE))
				{
					this.dispatchEvent(new MiracleEvent(MiracleEvent.REMOVED_FROM_STAGE));
				}
				_currentFrame = 0;
				_onStage = false;
				this.afterRemove();
			}
		}

		miracle_internal function dispose():void
		{
			transformation.dispose();
			_onStage = _visible = _isAnimated = _mouseEnable = _demandAnimationInstance = false;
			_currentFrame = z = 0;
			_mesh = null;
			_animation = null;
			_animationId = null;
			transformation = null;
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		protected function afterDraw():void
		{

		}

		protected function afterRemove():void
		{

		}

//		[Inline]
		protected final function demandAnimationInstance():void
		{
			if (_animation != null && _mesh != null)
			{
				_demandAnimationInstance = true;
			}
			else
			{
				throw new ArgumentError("Can not demand animation instance " +
						"without animation name and mesh name declaration");
			}
		}

		protected function afterAnimationDemand():void
		{

		}

		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		/**
		 * @private
		 */
//		[Inline]
		public final function get animation():String
		{
			return _animation;
		}

		/**
		 * Name of the animation that will be used for this display object
		 */
//		[Inline]
		public final function set animation(value:String):void
		{
			if (value != _animation)
			{
				_animation = value;
				_currentFrame = 0;
				_animationId = _mesh + DELIMITER + _animation;
				this.miracle_internal::remove();
			}
		}

		/**
		 * @private
		 */
//		[Inline]
		public final function get mesh():String
		{
			return _mesh;
		}

		/**
		 * Name of the mesh that will be used for this display object
		 */
//		[Inline]
		public final function set mesh(value:String):void
		{
			if (value != _mesh)
			{
				_mesh = value;
				_animationId = _mesh + DELIMITER + _animation;
				this.miracle_internal::remove();
			}
		}

//		[Inline]
		public final function get animationId():String
		{
			return _animationId;
		}

//Transformations

//		[Inline]
		public final function get width():int
		{
			return this.transformation.bounds.width;
		}

//		[Inline]
		public final function get height():int
		{
			return this.transformation.bounds.height;
		}

//		[Inline]
		public final function get x():Number
		{
			return this.transformation.matrix.tx;
		}

//		[Inline]
		public final function set x(value:Number):void
		{
			this.transformation.matrix.tx = value;
		}

//		[Inline]
		public final function get y():Number
		{
			return this.transformation.matrix.ty;
		}

//		[Inline]
		public final function set y(value:Number):void
		{
			this.transformation.matrix.ty = value;
		}

//		[Inline]
		public final function get scaleX():Number
		{
			return this.transformation.matrix.scaleX;
		}

//		[Inline]
		public final function set scaleX(value:Number):void
		{
			this.transformation.matrix.scaleX = value;
		}

//		[Inline]
		public final function get scaleY():Number
		{
			return this.transformation.matrix.scaleY;
		}

//		[Inline]
		public final function set scaleY(value:Number):void
		{
			this.transformation.matrix.scaleY = value;
		}

//		[Inline]
		public final function get skewX():Number
		{
			return this.transformation.matrix.skewX;
		}

//		[Inline]
		public final function set skewX(value:Number):void
		{
			this.transformation.matrix.skewX = value;
		}

//		[Inline]
		public final function get skewY():Number
		{
			return this.transformation.matrix.skewY;
		}

//		[Inline]
		public final function set skewY(value:Number):void
		{
			this.transformation.matrix.skewY = value;
		}

//		[Inline]
		public final function set direction(value:int):void
		{
			value = value < 0 ? -1 : 1;
			this.transformation.matrix.flipX = value;
			this.transformation.matrix.scaleX *= value;
		}

//		[Inline]
		public final function get direction():int
		{
			return this.transformation.matrix.flipX;
		}

//		[Inline]
		public final function get alpha():Number
		{
			//revert alphaMultiplier to alpha value
			return 1 - this.transformation.color.alphaMultiplier;
		}

//		[Inline]
		public final function set alpha(value:Number):void
		{
			//fix value if it not in 0 1 diapason
			value = value > 1 ? 1 : value < 0 ? 0 : value;
			value = 1 - value;//revert value for right alpha transformation
			this.transformation.color.alphaMultiplier = value;

			if (value > 0)
			{
				this.transformation.color.type |= Color.ALPHA;
			}
			else if ((this.transformation.color.type & Color.ALPHA) != 0)
			{
				this.transformation.color.type ^= Color.ALPHA;
			}
		}

//		[Inline]
		public final function get visible():Boolean
		{
			return _visible;
		}

		public function set visible(value:Boolean):void
		{
			_visible = value;
		}

//		[Inline]
		public final function set position(value:Vector3D):void
		{
			this.transformation.matrix.tx = value.x;
			this.transformation.matrix.ty = value.y;
		}

//		[Inline]
		public final function get isAnimated():Boolean
		{
			return _isAnimated;
		}

		//end of transformations
		//playback
//		[Inline]
		public final function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			_currentFrame = value;
		}

//		[Inline]
		protected final function get animationInstance():AnimationHelper
		{
			return _animationInstance;
		}

//		[Inline]
		protected final function set animationInstance(value:AnimationHelper):void
		{
			_animationInstance = value;
		}

		miracle_internal function set animationInstance(value:AnimationHelper):void
		{
			_animationInstance = value;
			this.afterAnimationDemand();
		}

		miracle_internal function get animationInstance():AnimationHelper
		{
			return _animationInstance;
		}

		miracle_internal function get demandAnimationInstance():Boolean
		{
			return _demandAnimationInstance;
		}

		miracle_internal function set demandAnimationInstance(value:Boolean):void
		{
			_demandAnimationInstance = value;
		}

//		[Inline]
		public final function get onStage():Boolean
		{
			return _onStage;
		}

//		[Inline]
		public final function get mouseEnable():Boolean
		{
			return _mouseEnable;
		}

//		[Inline]
		public final function set mouseEnable(value:Boolean):void
		{
			_mouseEnable = value;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
