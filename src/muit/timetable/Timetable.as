package muit.timetable
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	
	import muit.timetable.event.TimetableEvent;
	import muit.timetable.model.Reserve;
	import muit.timetable.model.Resource;
	import muit.timetable.parts.LoadingCurtain;
	import muit.timetable.parts.ReserveBox;
	import muit.timetable.skin.ReserveBoxSkin;
	import muit.timetable.util.DateUtil;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.graphics.Stroke;
	import mx.styles.CSSStyleDeclaration;
	
	import org.hamcrest.mxml.object.Null;
	import org.osmf.layout.AbsoluteLayoutFacet;
	import org.osmf.metadata.TemporalFacet;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.components.SkinnableContainer;

	[Style(name="reserveBoxFillColor",type="uint",format="Color",inherit="no")]
	
	[Style(name="reserveBoxAlpha",type="Number",format="Number",inherit="no")]

	[Style(name="reserverNameTxtColor",type="uint",format="Color",inherit="no")]

	[Style(name="reserveBoxBorderColor",type="uint",format="Color",inherit="no")]

	/**
	 * セルが選択された時に発行されるイベント。
	 * この時点で予約ボックスは配置されるが、まだ確定はされていない状態。
	 * アプリケーション側はこのイベントを受け取った後、サーバへの登録処理を行い、
	 * commitReservationメソッドを呼び出して該当の予約ボックスを定着させるか、
	 * 登録後の状態でサーバから一覧取得を行い、reservesプロパティの更新を行う必要がある。
	 */	
	[Event(name="timeSelected", type="muit.timetable.event.TimetableEvent")]

	/**
	 * 予約ボックスの削除ボタンが押下された際に発行されるイベント。
	 * 当該クラス内の処理から発行しているのではなく、ReserveBoxクラスが 
	 * ownerオブジェクト、つまり当該クラスから発行させている。
	 * このイベントが発行されても、当該クラスの予約情報は変化しないので、
	 * サーバから一覧取得を行い、reservesプロパティの更新を行う必要がある。
	 */	
	[Event(name="reserveDeleted", type="muit.timetable.event.TimetableEvent")]
	
	/**
	 * 予約ボックスの編集ボタンが押下された際に発行されるイベント。
	 * 当該クラス内の処理から発行しているのではなく、ReserveBoxクラスが 
	 * ownerオブジェクト、つまり当該クラスから発行させている。
	 * このイベントが発行されても、当該クラスの予約情報は変化しないので、
	 * サーバから一覧取得を行い、reservesプロパティの更新を行う必要がある。
	 */	
	[Event(name="reserveEdit", type="muit.timetable.event.TimetableEvent")]

	/**
	 * 
	 */	
	[Event(name="reserveMoved", type="muit.timetable.event.TimetableEvent")]


	[Event(name="reserveChanged", type="muit.timetable.event.TimetableEvent")]
	
	/**
	 * 既に予約ボックスが配置されているセルが選択された時、
	 * あるいは、既に予約ボックスが配置されているセルに、既存予約ボックスが移動してきた場合
	 * に発行されるイベント。
	 * 予約ボックス上のボタンが押下されても発行される。
	 */	
	[Event(name="cautionAllreadyReserved", type="muit.timetable.event.TimetableEvent")]

	[Event(name="cautionOverflowed", type="muit.timetable.event.TimetableEvent")]
	
	public class Timetable extends SkinnableContainer
	{
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Constant Variable
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public static const ERROR001_ID:String = "TimetableError001";
		public static const ERROR001_NAME:String = "タイムテーブルスタート時間不正";
		public static const ERROR001_MESSAGE:String = "タイムテーブルスタート時間は０時から２３時の間で指定してください。";

		public static const ERROR002_ID:String = "TimetableError002";
		public static const ERROR002_NAME:String = "タイムテーブルエンド時間不正";
		public static const ERROR002_MESSAGE:String = "タイムテーブルエンド時間は１時から２４時の間で指定してください。";
		
		public static const ERROR003_ID:String = "TimetableError003";
		public static const ERROR003_NAME:String = "タイムテーブルエンド時間不正";
		public static const ERROR003_MESSAGE:String = "タイムテーブルのスタート時間は、エンド時間より前に指定されなければいけません。";

		public static const ERROR004_ID:String = "TimetableError004";
		public static const ERROR004_NAME:String = "対象日数の最大値超過";
		public static const ERROR004_MESSAGE:String = "対象日数の最大値を超過しています。";

		public static const ERROR005_ID:String = "TimetableError005";
		public static const ERROR005_NAME:String = "対象リソース数の最大値超過";
		public static const ERROR005_MESSAGE:String = "対象リソース数の最大値を超過しています。";

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Private Valiable
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var rowCnt:int;
		private var colCnt:int;
		private var rowHeight:Number;
		private var colWidth:Number;

		private var timeTxtList:Array = new Array();
		private var dateTxtList:Array = new Array();
		private var resourceTxtList:Array = new Array();
		public var reserveBoxList:ArrayCollection = new ArrayCollection();		// Debug用に一時的にpublic化
		private var days:ArrayCollection = new ArrayCollection([new Date()]);
		
		private var currentMouseOnPos:Point = new Point();
		private var currentMouseOnIdx:Point = new Point();
		private var currentCellCnt:int = 0;
		
		private var highlightRect:BorderContainer = new BorderContainer();
		
		private var currentTargetReserveBox:ReserveBox = new ReserveBox();
		private var dragBox:ReserveBox;
		private var loadingCurtain:LoadingCurtain;

		private var highlightRectFirstY:int;
		private var distanceFromMouseIdxToDragBoxIdx:int;

		private var isAllowHighlight:Boolean = true;
		private var isMouseDown:Boolean = false;
		
		private var isResizingReserveBoxNow:Boolean = false;

		private var debugTxt:Text = new Text();
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// ACCESSER
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserves
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * Reserveオブジェクトは実体としては持たず、
		 * set時にReserveBoxに埋め込み、
		 * get時にReserveBoxから取り出す。
		 *  
		 */		
		private var _reserves:ArrayCollection = null;	// このprivate変数を直接参照、更新しては駄目。

		public function get reserves():ArrayCollection
		{
			var ret:ArrayCollection = new ArrayCollection();
			for each(var rb:ReserveBox in this.reserveBoxList)
			{
				ret.addItem(rb.reserve);
			}
			return ret;
		}

		public function set reserves(value:ArrayCollection):void
		{
			for each (var oldRsv:ReserveBox in this.reserveBoxList)
			{
				this.removeElement(oldRsv);
			}
			
			this.reserveBoxList = new ArrayCollection();
			for each(var rsv:Reserve in value)
			{
				var rb:ReserveBox = new ReserveBox();
				rb.reserve = rsv;
				rb = this.setReserveBoxPosition(rb);
				this.addElement(rb);
				this.reserveBoxList.addItem(rb);
				rb.addEventListener(TimetableEvent.DRAGSTART, reserveBoxDragstartHandler);
				rb.addEventListener(TimetableEvent.RESIZESTART, reserveBoxResizestartHandler);
				this.setReserveBoxStyle(rb);
			}
			
			this.invalidateDisplayList();
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// resources
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * Resourceオブジェクトを格納するリスト。
		 */		
		private var _resources:ArrayCollection = new ArrayCollection();
		[Bindable]
		public function get resources():ArrayCollection
		{
			return _resources;
		}
		public function set resources(value:ArrayCollection):void
		{

			if(value.length > this.maxResourceCount)
			{
				commonErrorHandler(getError(ERROR005_ID,ERROR005_NAME,ERROR005_MESSAGE));
				return;
			}

			_resources = value;

			this.invalidateDisplayList();
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// startTime
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * タイムテーブルの開始時間。
		 * デフォルトは９時。
		 */		
		private var _startTime:int = 9;
		[Bindable]
		public function get startTime():int
		{
			return _startTime;
		}
		public function set startTime(value:int):void
		{
			if(value < 0 && value > 24)
			{
				commonErrorHandler(getError(ERROR001_ID,ERROR001_NAME,ERROR001_MESSAGE));
			}
			
			if(value >= this.endTime)
			{
				commonErrorHandler(getError(ERROR003_ID,ERROR003_NAME,ERROR003_MESSAGE));
			}
			
			_startTime = value;
			this.invalidateDisplayList();
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// endTime
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * タイムテーブルの終了時間。
		 * デフォルトは18時。 
		 */		
		private var _endTime:int = 18;
		[Bindable]
		public function get endTime():int
		{
			return _endTime;
		}
		public function set endTime(value:int):void
		{
			if(value < 1 && value > 25)
			{
				commonErrorHandler(getError(ERROR002_ID,ERROR002_NAME,ERROR002_MESSAGE));
			}
			
			if(value <= this.startTime)
			{
				commonErrorHandler(getError(ERROR003_ID,ERROR003_NAME,ERROR003_MESSAGE));
			}

			_endTime = value;
			this.invalidateDisplayList();
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// firstColWidth
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * 一番左の列の幅。 
		 */		
		private var _firstColWidth:int = 50;
		public function get firstColWidth():int
		{
			return _firstColWidth;
		}
		public function set firstColWidth(value:int):void
		{
			_firstColWidth = value;
		}
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// daysRowHeight
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _daysNameRowHeight:int = 20;

		/**
		 * 日付を表示する行の高さ
		 */		
		public function get daysNameRowHeight():int
		{
			return _daysNameRowHeight;
		}

		/**
		 * @private 
		 */		
		public function set daysNameRowHeight(value:int):void
		{
			_daysNameRowHeight = value;
		}


		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// resourceNameRowHeight
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _resourceNameRowHeight:int = 20;

		/**
		 * リソース情報を表示する行の高さ
		 */
		public function get resourceNameRowHeight():int
		{
			return _resourceNameRowHeight;
		}

		/**
		 * @private
		 */
		public function set resourceNameRowHeight(value:int):void
		{
			_resourceNameRowHeight = value;
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// dateRanges
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _dateRanges:Array;

		/**
		 * 日付範囲。DateChooserのselectedRangesと同じデータの持ち方。 
		 */		
		public function get dateRanges():Array
		{
			return _dateRanges;
		}

		public function set dateRanges(value:Array):void
		{

			//初期値設定
			if(value == null || value.length == 0)
			{
				var dr:Object = new Object();
				var today:Date = new Date();
				dr.rangeStart=today;
				dr.rangeEnd=today;
				value = [dr];
			}
			
			var td:Date = value[0].rangeStart as Date;
			var ed:Date = value[0].rangeEnd as Date;

			if(this.maxDateRange < DateUtil.getDaysLength(td, ed))
			{
				commonErrorHandler(getError(ERROR004_ID,ERROR004_NAME,ERROR004_MESSAGE));
				return;
			}
			
			_dateRanges = value;
			
			this.days = new ArrayCollection();
			
			while(DateUtil.date1LessThanOrEqualDate2(td,ed))
			{
				this.days.addItem(td);
				td = new Date(DateUtil.plusDay(td,1));
			}
			

			this.invalidateDisplayList();
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// maxDateRange
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _maxDateRange:Number = 5;

		public function get maxDateRange():Number
		{
			return _maxDateRange;
		}

		public function set maxDateRange(value:Number):void
		{
			_maxDateRange = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// maxResourceCount
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _maxResourceCount:Number = 5;

		public function get maxResourceCount():Number
		{
			return _maxResourceCount;
		}

		public function set maxResourceCount(value:Number):void
		{
			_maxResourceCount = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// nowLoading
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _nowLoading:Boolean = false;
		
		[Bindable]
		public function get nowLoading():Boolean
		{
			return _nowLoading;
		}

		public function set nowLoading(value:Boolean):void
		{
			_nowLoading = value;
			if(value)
			{
				if(!this.loadingCurtain)
				{
					this.loadingCurtain = new LoadingCurtain();
					this.addElement(this.loadingCurtain);
				}
				this.loadingCurtain.width = this.unscaledWidth;
				this.loadingCurtain.height = this.unscaledHeight;
			}
			else
			{
				if(this.loadingCurtain && this.contains(this.loadingCurtain))
				{
					this.removeElement(this.loadingCurtain);
					this.loadingCurtain = null;
				}
			}
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// errorHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * エラー処理を行う関数。
		 * 設定しなければ、内部の共通エラー処理機能が稼働する。
		 * 単純にAlertを出力するだけ。 
		 */		
		private var _errorHandler:Function;
		public function get errorHandler():Function
		{
			return _errorHandler;
		}
		public function set errorHandler(value:Function):void
		{
			_errorHandler = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// dayNames
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _dayNames:Array = ["日","月","火","水","木","金","土"]
		public function get dayNames():Array
		{
			return _dayNames;
		}
		public function set dayNames(value:Array):void
		{
			_dayNames = value;
			
			//曜日表示が変わったら描画し直しが必要
			this.invalidateDisplayList();
		}

;
		

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// CONSTRUCTOR
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function Timetable()
		{
			super();

			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("muit.timetable.Timetable"))
			{
				var timetableStyle:CSSStyleDeclaration = new CSSStyleDeclaration();
				timetableStyle.defaultFactory = function():void
				{
					this.reserveBoxFillColor = 0x000000;
					this.reserveBoxAlpha = 0.5;
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("muit.timetable.Timetable", timetableStyle, true);
			}
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,creationCompleteHandler);
			this.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// PUBLIC METHOD
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// allowHighlight
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function allowHightlight():void
		{
			this.isAllowHighlight = true;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// denyHightlight
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function denyHightlight():void
		{
			this.isAllowHighlight = false;
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// cancelToReserve
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function cancelToReserve():void
		{
			var rb:ReserveBox = this.reserveBoxList.getItemAt(this.reserveBoxList.length - 1) as ReserveBox;
			this.removeElement(rb);
			this.reserveBoxList.removeItemAt(this.reserveBoxList.length - 1);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// OVERRIDE METHOD
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// createChildren
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		override protected function createChildren():void
		{
			super.createChildren();
			
			// ハイライト矩形の初期設定。
			this.addElement(highlightRect);
			highlightRect.setStyle("backgroundColor",0xFF0000);
			highlightRect.setStyle("borderVisible",false);
			highlightRect.setStyle("backgroundAlpha",0.3);
			highlightRect.visible = false;

			// 時刻表示を設置する処理
			var now:int = 0;
			while( now < 24)
			{
				var timeTxt:Text = new Text();
				timeTxt.text = now.toString() + ":00";
				timeTxt.width = 50;
				timeTxt.height = 20;
				timeTxt.setStyle("textAlign","right");
				timeTxt.visible = false;
				
				this.addElement(timeTxt);
				this.timeTxtList.push(timeTxt);
				
				now++;
			}
			
			// デバッグ用Text部品の配置
			this.addElement(debugTxt);
			debugTxt.visible = false; //隠しとく
			
			
			// 日付行に配置する、日付テキストオブジェクトを配置する
			for(var i:int=0; i<this.maxDateRange; i++)
			{
				var dateTxt:Text = new Text();
				dateTxt.width = 50;
				dateTxt.height = 15;
				dateTxt.setStyle("textAlign","center");
				dateTxt.visible = false;
				this.addElement(dateTxt);
				this.dateTxtList.push(dateTxt);
			}
			
			var bmax:int = this.maxDateRange * this.maxResourceCount;
			for(var b:int=0; b<bmax; b++)
			{
				//var rscTxt:Text = new Text();
				var rscTxt:Label = new Label();
				rscTxt.visible = false;
				this.addElement(rscTxt);
				this.resourceTxtList.push(rscTxt);
			}
			
			for each(var rsb:ReserveBox in this.reserveBoxList)
			{
				rsb.visible = false;
				this.addElement(rsb);
			}
			
			trace("finished createChildren");
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// commitProperties
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		override protected function commitProperties():void
		{
			super.commitProperties();
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// updateDisplayList
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			trace("#############updateDisplayList");
			
			// デバッグ用Text部品の幅設定
			this.debugTxt.width = unscaledWidth;
			
			// 行数、列数の決定
			rowCnt = (endTime - startTime) * 4 + 2;
			colCnt = resources.length * days.length + 1;

			// 行の高さ、列の幅の決定
			rowHeight = (unscaledHeight - resourceNameRowHeight - daysNameRowHeight) / (rowCnt - 2);
			colWidth = (unscaledWidth - firstColWidth) / (colCnt - 1);

			// ついでにハイライト矩形のサイズも設定
			highlightRect.width = colWidth;
			highlightRect.height = rowHeight;
			
			// 一旦すべての部品を非表示にする。この後、該当の時刻表時を表示化したり、場所を調整したりする。
			this.vanishAllObjects();

			//罫線描画
			this.drawLines(unscaledWidth,unscaledHeight);
			
			//予約ボックスのサイズと配置場所を決定
			this.decideReserveBoxPositionAndSize(unscaledWidth, unscaledHeight);
			
			//ローディングカーテンの設定
			if(this.loadingCurtain)
			{
				this.loadingCurtain.width = unscaledWidth;
				this.loadingCurtain.height = unscaledHeight;
			}

			super.updateDisplayList(unscaledWidth, unscaledHeight);

			trace("finished updateDisplayList");
		}

		override public function styleChanged(styleProp:String):void 
		{
			super.styleChanged(styleProp);
			
			// Check to see if style changed. 
			if (styleProp=="reserveBoxFillColor" || styleProp=="reserveBoxAlpha") 
			{
				this.invalidateDisplayList();
			}
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// EVENT HANDLER
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function creationCompleteHandler(event:FlexEvent):void
		{
			trace("#creationCompleteHandler");
			
		}//end of func
		
		private function enterFrameHandler(event:Event):void
		{
			if(this.nowLoading) return;
			
			if(this.isResizingReserveBoxNow)
			{
				this.changeBoxSizeWithMouse(this.currentTargetReserveBox);
				return;
			}
			
			if(this.dragBox != null)	// Drag中と判断。
			{
				trace("now dragging");
				this.highlightChaseMouse(this.dragBox);
				return;
			}
			
			drawMouseOver(this.mouseX, this.mouseY);
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			trace("mouseDownHandler");
			
			if(this.nowLoading) return;
			
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			this.isMouseDown = true;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// mouseClickHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * クリックというより、MouseUPのタイミングをとらえるためのメソッド 
		 * @param event
		 * 
		 */		
		private function mouseClickHandler(event:MouseEvent):void
		{
			trace("mouseClickHandler");
			
			this.removeEventListener(MouseEvent.CLICK,mouseClickHandler);
			this.isMouseDown = false;
			
			if(this.isResizingReserveBoxNow)
			{
				var tevent_resize:TimetableEvent = new TimetableEvent(TimetableEvent.RESERVE_CHANGED);
				tevent_resize.reserve = this.currentTargetReserveBox.reserve;
				var resized_rsv:Reserve = this.getReserveFromReserveBox(this.currentTargetReserveBox.positionIndex.x, this.currentTargetReserveBox.positionIndex.y, this.currentTargetReserveBox.cellCount - 1);
				tevent_resize.reserve.endTimeHour = resized_rsv.endTimeHour;
				tevent_resize.reserve.endTimeMin = resized_rsv.endTimeMin;
				this.dispatchEvent(tevent_resize);
				
				this.isResizingReserveBoxNow = false;
				this.clearCurrentVar();
				
				return;
			}
			
			// マウスダウンされたセルに、予約ボックスが既にいないか確認。いるなら、ここで終わり。
			var currentCellIdx:Point = this.getCellIndex(this.mouseX, this.mouseY);
			var dummyRb:ReserveBox = new ReserveBox();
			dummyRb.positionIndex.x = currentCellIdx.x;
			dummyRb.positionIndex.y = currentCellIdx.y;
			dummyRb.cellCount = 0; //セル一個分の時は、cellCountはゼロ。
			if(this.containReservedCell(dummyRb, this.reserveBoxList)) return;
			
			// まずは ReserveBox を生成
			var rbox:ReserveBox = new ReserveBox();
			
			var ccc:int = this.currentCellCnt;
			var cmi:Point = this.currentMouseOnIdx;
			var cmix:Number = this.currentMouseOnIdx.x;
			var cmiy:Number = this.currentMouseOnIdx.y;
			var cmp:Point = this.currentMouseOnPos;
			var cmpx:Number = this.currentMouseOnPos.x;
			var cmpy:Number = this.currentMouseOnPos.y;
			
			
			if(ccc < 0)
			{
				// カーソルが上に上がった時には、y の値を更新してあげなければならない
				
				rbox.positionIndex = new Point( cmix, cmiy + ccc);
				rbox.positionPoint = new Point(	cmpx, cmpy + (ccc * this.rowHeight));
			}
			else
			{
				// このタイミングでカーソルがあたっている、セルのIndexを設定する
				rbox.positionIndex = cmi;
				rbox.positionPoint = cmp;
			}
			
			this.debugTxt.text = "currentCellCount : " + ccc;
			
			rbox.cellCount = Math.abs(ccc);
			rbox.x = rbox.positionPoint.x;
			rbox.y = rbox.positionPoint.y;
			rbox.width = this.colWidth;
			rbox.height = this.rowHeight * (rbox.cellCount + 1);
			this.currentTargetReserveBox = rbox;

			// 選択した領域に、予約済みのセルがあれば、イベント発行して終わる。
			if(this.containReservedCell(rbox, this.reserveBoxList))
			{
				// dispatch event
				var tcevent:TimetableEvent = new TimetableEvent(TimetableEvent.CAUTION_ALLREADY_RESERVED);
				this.dispatchEvent(tcevent);
				this.isMouseDown = false;

				//current系の編集は初期化
				this.clearCurrentVar();
				return;
			}
			
			// reserveBox に reserveオブジェクトをセット
			var reserve:Reserve = this.getReserveFromReserveBox(rbox.positionIndex.x, rbox.positionIndex.y, rbox.cellCount);
			reserve.reserverName = "Current User";
			rbox.reserve = reserve;
			
			this.setReserveBoxStyle(rbox);
			
			// ここまできて、ようやく配置。
			this.addElement(rbox);
			this.reserveBoxList.addItem(rbox);
			rbox.addEventListener(TimetableEvent.DRAGSTART, reserveBoxDragstartHandler);
			rbox.addEventListener(TimetableEvent.RESIZESTART, reserveBoxResizestartHandler);
			
			var tevent:TimetableEvent = new TimetableEvent(TimetableEvent.TIME_SELECTED);
			tevent.cellCount = rbox.cellCount;
			tevent.cellIndexPoint = rbox.positionIndex;
			tevent.reserve = rbox.reserve;
			this.dispatchEvent(tevent);

			//current系の編集は初期化
			this.clearCurrentVar();
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserveBoxDragstartHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function reserveBoxDragstartHandler(event:TimetableEvent):void
		{
			this.dragBox = new ReserveBox();
			this.dragBox.reserve = event.reserve;
			this.dragBox.positionIndex = ReserveBox(event.currentTarget).positionIndex;
			this.dragBox.positionPoint = ReserveBox(event.currentTarget).positionPoint;
			this.dragBox.cellCount = ReserveBox(event.currentTarget).cellCount;
			this.dragBox.x = ReserveBox(event.currentTarget).x;
			this.dragBox.y = ReserveBox(event.currentTarget).y;
			this.dragBox.width = ReserveBox(event.currentTarget).width;
			this.dragBox.height = ReserveBox(event.currentTarget).height;
			this.dragBox.isDragging = true;
			this.setReserveBoxStyle(this.dragBox);
			
			this.addElement(this.dragBox);
			
			var currentMouseIndex:Point = this.getCellIndex(this.mouseX, this.mouseY);
			this.distanceFromMouseIdxToDragBoxIdx = currentMouseIndex.x - this.dragBox.positionIndex.x;
			
			
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserveBoxResizestartHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function reserveBoxResizestartHandler(event:TimetableEvent):void
		{
			trace("#reserveBoxResizestartHandler");
			this.currentTargetReserveBox = event.currentTarget as ReserveBox;
			this.isResizingReserveBoxNow = true;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// mouseUpHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * MouseUpされ、ドラッグが終わった時に稼働する処理。
		 * 移動先が予約済みの場合は、TimetableEvent.CAUTION_ALLREADY_RESERVED　イベントを発行する。
		 * 異動先に予約変更できる場合は、TimetableEvent.MOVE　イベントを発行する。
		 * アプリケーションは、イベントから新予約を取得し、サーバサイドにUpdateを投げる。
		 * 正常終了後、反映後のスケジュール一覧を取得し、タイムテーブルを更新する。
		 * タイムテーブル内で、スケジュール変更反映処理は行わない。
		 * 
		 * 最後には、dragBox をnull化する。これがnullじゃないかどうかで、ドラッグ処理をするかどうか分岐されるため。
		 *  
		 * @param event
		 */		
		private function mouseUpHandler(event:MouseEvent):void
		{
			//ハイライトボックスをドラッグしているとき
			if(this.dragBox != null)
			{
				if(this.containReservedCell(this.dragBox, this.reserveBoxList))
				{
					var tevent_caution:TimetableEvent = new TimetableEvent(TimetableEvent.CAUTION_ALLREADY_RESERVED);
					tevent_caution.reserve = this.dragBox.reserve;
					this.dispatchEvent(tevent_caution);
				}
				else
				{
					var rsv:Reserve = this.dragBox.reserve;
					var movedRsv:Reserve = this.getReserveFromReserveBox(this.dragBox.positionIndex.x, this.dragBox.positionIndex.y, this.dragBox.cellCount - 1);
					rsv.resourceID = movedRsv.resourceID;
					rsv.date = movedRsv.date;
					rsv.startTimeHour = movedRsv.startTimeHour;
					rsv.startTimeMin = movedRsv.startTimeMin;
					rsv.endTimeHour = movedRsv.endTimeHour;
					rsv.endTimeMin = movedRsv.endTimeMin;
					
					if(rsv.startTimeHour < this.startTime || rsv.endTimeHour >= this.endTime)
					{
						//移動後の時間が、今のタイムテーブルからはみ出すようなら、移動させない。
						var tevent_caution_of:TimetableEvent = new TimetableEvent(TimetableEvent.CAUTION_OVERFLOWED);
						tevent_caution_of.reserve = this.dragBox.reserve;
						this.dispatchEvent(tevent_caution_of);
					}
					else
					{
						var tevent_move:TimetableEvent = new TimetableEvent(TimetableEvent.RESERVE_MOVED);
						tevent_move.reserve = rsv;
						this.dispatchEvent(tevent_move);
					}
				}
				
				this.removeElement(this.dragBox);
				this.dragBox = null;
				this.isMouseDown = false;
			}
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// METHOD
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		private function vanishAllObjects():void
		{
			// 一旦すべての時刻表時を非表示にする。この後、該当の時刻表時を表示化したり、場所を調整したりする。
			for each(var txt:Text in this.timeTxtList)
			{
				txt.visible = false;
			}
			
			// 一旦すべての日付表時を非表示にする。この後、該当の表示表時を表示化したり、場所を調整したりする。
			for each(var dayTxt:Text in this.dateTxtList)
			{
				dayTxt.visible = false;
			}
			
			// 一旦すべてのリソース名表示を非表示にする。この後、該当の表示表時を表示化したり、場所を調整したりする。
			//for each(var rsTxt:Text in this.resourceTxtList)
			for each(var rsTxt:Label in this.resourceTxtList)
			{
				rsTxt.visible = false;
			}
			
			// 一旦すべての予約ボックスを非表示にする。この後、該当の表示表時を表示化したり、場所を調整したりする。
			for each(var rsb:ReserveBox in this.reserveBoxList)
			{
				rsb.visible = false;
			}
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// drawMouseOver
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * マウスオーバーを描画するための処理。
		 * ドラッグしている状態の、ハイライトを描画するための処理。
		 *  
		 * @param x
		 * @param y
		 */		
		private function drawMouseOver(x:Number, y:Number):void
		{
			// ハイライト許可されていない時は、リターンしちゃう。
			if(!this.isAllowHighlight) return;
			
			// マウス座標から所属するセルのIndexを取得する。
			var cellIdx:Point = getCellIndex(x, y);
			if(cellIdx == null)
			{
				// this.debugTxt.text = "mouse x : " + x + ", y : " + y;
				return;	
			}
			
			// this.debugTxt.text = "mouse x : " + x + ", y : " + y + 
			// 	"  hightlight position : x " + cellIdx.x.toString() + " ,y : " + cellIdx.y.toString();

			// セルのIndexの座標を取得する。
			var cellPos:Point = getCellPosition(cellIdx);

			// カーソル位置が、同じCell上にあることを確認。
			// そうであれば、何もぜずにこのメソッドを終わる。
			if(cellPos == null)
			{
				this.highlightRect.visible = false;
				return;	
			}
			else
			{
				if(this.currentMouseOnIdx == null)
				{
					return;
				}
				
				if(cellIdx.x == this.currentMouseOnIdx.x && cellIdx.y == this.currentMouseOnIdx.y)
				{
					return;
				}
			}
			
			// マウスダウンしている状態であれば、ハイライト矩形のサイズを変更する。
			if(this.isMouseDown)
			{
				this.currentCellCnt = cellIdx.y - this.currentMouseOnIdx.y;
				
				// カーソルが上に上がった時には、y の値を更新してあげなければならない
				if( this.currentCellCnt < 0)
				{
					this.highlightRect.y = this.highlightRectFirstY + this.currentCellCnt * this.rowHeight;
				}
				
				this.highlightRect.height = (Math.abs(this.currentCellCnt) + 1) * this.rowHeight;
			}
			// マウスダウンしていない状態なので、ハイライト矩形の場所を移動する。
			else
			{
				this.highlightRect.x = cellPos.x;
				this.highlightRect.y = cellPos.y;
				this.highlightRect.height = this.rowHeight;	// ハイライト矩形を元のサイズに戻す
				this.highlightRect.visible = true;			// このタイミングでマウスオンしている時は非表示なので、表示に切り替える。

				// マウスダウンした最初のセルのY座標を確保しておく。
				// ドラッグした時の矩形サイズ変更の時の、基準値となる。
				this.highlightRectFirstY = this.highlightRect.y;

				// マウスオンしている、Index、座標を確保しておく。
				this.currentMouseOnPos = cellPos;
				this.currentMouseOnIdx = cellIdx;
			}
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// drawLines
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function drawLines(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// まずは全罫線クリア
			this.graphics.clear();
			
			// ラインスタイルの設定
			this.graphics.lineStyle(1, 0x333333, 1);
			
			// 外枠の描画
			this.graphics.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 10, 10);

			// 縦罫線の描画
			this.drawColLines(unscaledWidth,unscaledHeight);
			
			// 横罫線の描画
			this.drawRowLines(unscaledWidth,unscaledHeight);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// drawColLines
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function drawColLines(unscaledWidth:Number, unscaledHeight:Number):void
		{
			for(var c:int = 0; c < colCnt - 1; c++)
			{
				if(c == 0)
				{
					// 一番左の列の右の罫線描画
					//this.graphics.lineStyle(1, 0xff0000, 1);
					this.graphics.lineStyle(1, 0x333333, 1);
					this.graphics.moveTo(firstColWidth, 0);
					this.graphics.lineTo(firstColWidth, unscaledHeight);
					
					//日付Txtの設置
					var dayIdx0:int = c;
					var day0:Date = this.days.getItemAt(dayIdx) as Date;
					
					var yobiStr0:String = "(" + this.dayNames[day0.getDay()] + ")";
					
					var targetDayTxt0:Text = this.dateTxtList[dayIdx];
					targetDayTxt0.text = (day0.getMonth() + 1).toString() + "/" + day0.getDate() + yobiStr0;
					targetDayTxt0.width = colWidth * resources.length;
					targetDayTxt0.height = daysNameRowHeight;
					targetDayTxt0.x = firstColWidth;
					targetDayTxt0.y = 0;
					targetDayTxt0.visible = true;
				}
				else
				{
					// 日付毎の縦罫線描画
					if( c % resources.length == 0)
					{
						// 罫線描画
						this.graphics.lineStyle(1, 0x333333, 1);
						this.graphics.moveTo(firstColWidth + colWidth * c, 0);
						this.graphics.lineTo(firstColWidth + colWidth * c, unscaledHeight);
						
						//日付Txtの設置
						var dayIdx:int = c / resources.length;
						var day:Date = this.days.getItemAt(dayIdx) as Date;

						var yobiStr:String = "(" + this.dayNames[day.getDay()] + ")";

						var targetDayTxt:Text = this.dateTxtList[dayIdx];
						targetDayTxt.text = (day.getMonth() + 1).toString() + "/" + day.getDate() + yobiStr;
						targetDayTxt.width = colWidth * resources.length;
						targetDayTxt.height = daysNameRowHeight;
						targetDayTxt.x = firstColWidth + colWidth * c;
						targetDayTxt.y = 0;
						targetDayTxt.visible = true;
					}
						//  リソース毎の縦罫線描画
					else
					{
						this.graphics.lineStyle(1, 0xCCCCCC, 1);
						this.graphics.moveTo(firstColWidth + colWidth * c, this.daysNameRowHeight);
						this.graphics.lineTo(firstColWidth + colWidth * c, unscaledHeight);
					}
				}
				
				//　ResourceText の配置
				var rscTxt:Label = this.resourceTxtList[c] as Label;
				var rscIdx:int = c % this.resources.length;
				var rsc:Resource = this.resources.getItemAt(rscIdx) as Resource;
				rscTxt.text = rsc.resourceName;
				if(rsc.resourceProps != null && rsc.resourceProps.length > 0)
				{
					rscTxt.toolTip = "";
					for each(var prop:Object in rsc.resourceProps)
					{
						rscTxt.toolTip += prop.key + ":" + prop.value + "   ";
					}
				}
				rscTxt.x = this.firstColWidth + colWidth * c;
				rscTxt.y = this.daysNameRowHeight;
				rscTxt.width = this.colWidth;
				rscTxt.height = this.resourceNameRowHeight;
				
				rscTxt.setStyle("textAlign", "center");
				rscTxt.setStyle("verticalAlign","middle");
				rscTxt.visible = true;
				
				rscTxt.addEventListener(MouseEvent.CLICK,function(event:Event):void{
					trace("xx");
				});
				
			}
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// drawRowLines
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * 横罫線の描画 
		 */		
		private function drawRowLines(unscaledWidth:Number, unscaledHeight:Number):void
		{
			for(var r:int = 0; r < rowCnt - 1; r++)
			{
				if( r == 0)
				{
					// 日付表示行下の罫線を描画
					this.graphics.lineStyle(1, 0x999999, 1);
					this.graphics.moveTo(firstColWidth, daysNameRowHeight);
					this.graphics.lineTo(unscaledWidth, daysNameRowHeight);
				}
				else if( r == 1)
				{
					// リソース情報表示行下の罫線を描画
					//this.graphics.lineStyle(1, 0xff0000, 1);
					this.graphics.lineStyle(1, 0x333333, 1);
					this.graphics.moveTo(0, daysNameRowHeight + resourceNameRowHeight);
					this.graphics.lineTo(unscaledWidth, daysNameRowHeight + resourceNameRowHeight);
					
					// 最初の時刻表時のText設定
					Text(this.timeTxtList[this.startTime]).x = firstColWidth - Text(this.timeTxtList[0]).width;
					Text(this.timeTxtList[this.startTime]).y = daysNameRowHeight + resourceNameRowHeight;
					Text(this.timeTxtList[this.startTime]).visible = true;
				}
				else
				{
					if( ( r - 1 ) % 4 == 0 )
					{
						// 時間毎の濃い罫線の描画
						this.graphics.lineStyle(1, 0x333333, 1);
						this.graphics.moveTo(0, daysNameRowHeight + resourceNameRowHeight + rowHeight * (r - 1));
						this.graphics.lineTo(unscaledWidth, daysNameRowHeight + resourceNameRowHeight + rowHeight * (r - 1));
						
						// 時間毎の時刻表時のText設定
						var time_i:int = Math.floor((r - 1) / 4);
						Text(this.timeTxtList[this.startTime + time_i]).x = firstColWidth - Text(this.timeTxtList[time_i]).width;
						Text(this.timeTxtList[this.startTime + time_i]).y = daysNameRowHeight + resourceNameRowHeight + rowHeight * (r - 1);
						Text(this.timeTxtList[this.startTime + time_i]).visible = true;
					}
					else
					{
						// １５分毎の罫線の描画
						this.graphics.lineStyle(1, 0x999999, 1);
						this.graphics.moveTo(firstColWidth, daysNameRowHeight + resourceNameRowHeight + rowHeight * (r - 1));
						this.graphics.lineTo(unscaledWidth, daysNameRowHeight + resourceNameRowHeight + rowHeight * (r - 1));
					}
				}
			}
		}
		
		/**
		 * 予約ボックスの配置場所を決定する処理。
		 * 
		 * @param unscaledWidth
		 * @param unscaledHeight
		 */
		private function decideReserveBoxPositionAndSize(unscaledWidth:Number, unscaledHeight:Number):void
		{
			for each(var rb:ReserveBox in reserveBoxList)
			{
				rb = this.setReserveBoxPosition(rb);
				
				this.setReserveBoxStyle(rb);
				
				if(rb.positionIndex != null)
				{
					//					trace(rb.reserve.reserverName + 
					//						"::: x:" + rb.positionIndex.x + ", y:" + rb.positionIndex.y + 
					//						", day::" + (rb.reserve.date.month + 1).toString() + "/" + rb.reserve.date.date + 
					//						", start::" + rb.reserve.startTimeHour + ":" + rb.reserve.startTimeMin +
					//						", end::" + rb.reserve.endTimeHour + ":" + rb.reserve.endTimeMin );
					
					rb.positionPoint = this.decideReserveBoxPosition(rb);
					rb.x = rb.positionPoint.x;
					rb.y = rb.positionPoint.y;

					var size:Point = this.decideReserveBoxSize(rb);
					rb.width = size.x;
					rb.height = size.y;
					
					if(rb.height > 0)
					{
						rb.visible = true;
					}
				}
			}

		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// decideReserveBoxPosition
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * 予約ボックスのポジションを決定する処理
		 *  
		 * @param rb
		 * @return 
		 * 
		 */		
		private function decideReserveBoxPosition(rb:ReserveBox):Point
		{
			var ret:Point = new Point();
			
			ret.x = this.firstColWidth + rb.positionIndex.x * this.colWidth;

			if(rb.positionIndex.y < 0 )
			{
				//rb.positionIndex.y がマイナスということは、タイムテーブルの上に突き抜けているということなので、
				//タイムテーブルのセルの一番上の y 座標をおいてあげる。
				ret.y = daysNameRowHeight + resourceNameRowHeight;
			}
			else
			{
				ret.y = daysNameRowHeight + resourceNameRowHeight + rb.positionIndex.y * this.rowHeight;
			}
			
			return ret;
		}
		
		private function decideReserveBoxSize(rb:ReserveBox):Point
		{
			var ret:Point = new Point();
			
			//width
			ret.x = this.colWidth;
			
			//height
			
			//下に突き抜けているかどうかの値
			//rowCount はヘッダー分２つ余計に入っているので、引いてあげる。
			var beyond:Number = rb.positionIndex.y + rb.cellCount - (this.rowCnt - 2);

			//上にも下にもつきぬけていたら
			if(beyond > 0 && rb.positionIndex.y < 0)
			{
				ret.y = (this.rowCnt - 2) * this.rowHeight;
				return ret;
			}
			else if(beyond > 0)
			{
				//下につきぬけていたら
				ret.y = (rb.cellCount - beyond) * this.rowHeight;
				return ret;
			}
			else if(rb.positionIndex.y < 0)
			{
				//上につきぬけていたら
				ret.y = (rb.cellCount  + rb.positionIndex.y) * this.rowHeight;
				return ret;
			}
			else
			{
				//つきぬけていなければ
				ret.y = rb.cellCount * this.rowHeight;
				return ret;
			}
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// highlightChaseMouse
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * 予約ボックスをドラッグしている最中に、予約ボックスの場所を決定させるメソッド。
		 * マウスに追随させるため、今のマウスカーソルの座標から、インデックス情報を取得する
		 * y座標はそのままドラッグボックスに設定すればいいが、
		 * x座標は、マウスダウンした時の、予約ボックスの先頭セルからの距離分引いてあげないといけない。 
		 */		
		private function highlightChaseMouse(target:ReserveBox):void
		{
			var currentMouseIdx:Point = this.getCellIndex(mouseX, mouseY);

			target.positionIndex = new Point(currentMouseIdx.x - this.distanceFromMouseIdxToDragBoxIdx, currentMouseIdx.y);
			target.positionPoint = this.getCellPosition(target.positionIndex);
			
			target.x = target.positionPoint.x;
			target.y = target.positionPoint.y;
			
			trace("dragBox x:" + target.x + " y:" + target.y);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// changeBoxSizeWithMouse
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function changeBoxSizeWithMouse(target:ReserveBox):void
		{
			var currentMouseIdx:Point = this.getCellIndex(mouseX, mouseY);
			
			// カーソルがタイムテーブルの外に出ると、null になるので、それをチェックアウト。
			if(currentMouseIdx)
			{
				var newCellCount:int = currentMouseIdx.y - target.positionIndex.y + 1;
				
				if(newCellCount > 0)
				{
					target.cellCount = newCellCount;
					var newSize:Point = this.decideReserveBoxSize(target);
					target.width = newSize.x;
					target.height = newSize.y;
				}
			}
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// getCellIndex
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * 座標から座標が所属するセルのIndexを取得する処理
		 *  
		 * @param x
		 * @param y
		 * @return 座標が所属するセルのIndex
		 */		
		private function getCellIndex(x:Number, y:Number):Point
		{
			if( x <= this.firstColWidth || x >= this.width)
			{
				return null;
			}
			else if( y <= ( daysNameRowHeight + resourceNameRowHeight) || y >= this.height)
			{
				return null;
			}
			else
			{
				var ret:Point = new Point();
				ret.x = Math.floor((x - this.firstColWidth) / colWidth);
				ret.y = Math.floor((y - ( daysNameRowHeight + resourceNameRowHeight)) / rowHeight);
				return ret;
			}
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// getCellPosition
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * セルIndexから、セル座標を返す処理
		 *  
		 * @param p
		 * @return セル座標
		 */		
		private function getCellPosition(p:Point):Point
		{
			var x:Number = p.x * colWidth + firstColWidth;
			var y:Number = p.y * rowHeight + ( daysNameRowHeight + resourceNameRowHeight);
			return new Point(x,y);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// getReserveBoxFromReserve
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * Reserve オブジェクトから　ReserveBox を生成して返す処理
		 *  
		 * @param reserve
		 * @return 
		 * 
		 */		
		protected function setReserveBoxPosition(reserveBox:ReserveBox):ReserveBox
		{
			var ci:int = 0;
			for each(var day:Date in this.days)
			{
				for each(var rs:Resource in this.resources)
				{
					if( DateUtil.equal(day,reserveBox.reserve.date) == true && rs.resourceID == reserveBox.reserve.resourceID)
					{
						var ri:int = reserveBox.reserve.startTimeHour * 4 + 
										reserveBox.reserve.startTimeMin / 15 - 
										this.startTime * 4;
						reserveBox.positionIndex = new Point(ci, ri);
						reserveBox.cellCount = (reserveBox.reserve.endTimeHour * 4 + reserveBox.reserve.endTimeMin / 15)
							- (reserveBox.reserve.startTimeHour * 4 + reserveBox.reserve.startTimeMin / 15);
						return reserveBox;
					}
					ci++;
				}
			}
			reserveBox.positionIndex = null;
			return reserveBox;
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// getReserveFromReserveBox
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * ReserveBoxのPositionIndexとCellCntから、予約時間を含めたReserveオブジェクトを返す処理
		 *  
		 * @param x
		 * @param y
		 * @param cellCnt
		 * @return 
		 * 
		 */		
		private function getReserveFromReserveBox(x:int, y:int, cellCnt:int):Reserve
		{
			var day:Date = this.days.getItemAt(Math.floor(x / this.resources.length)) as Date;
			var rs:Resource = this.resources.getItemAt(x % this.resources.length) as Resource;

			var st_hour:int = this.startTime + Math.floor(y / 4);
			var st_min:int = (y % 4) * 15;
			
			var ey:int = y + cellCnt + 1;
			var et_hour:int = this.startTime + Math.floor(ey / 4);
			var et_min:int = (ey % 4) * 15;
			
			//チェック処理
			var mindiff_time:int = (et_hour * 60 + et_min) - (st_hour * 60 + st_min);
			var mindiff_cnt:int = (cellCnt + 1) * 15;
			if(mindiff_time != mindiff_cnt) throw new Error("バグ！");
			
			var rb:Reserve = new Reserve();
			rb.date = day;
			rb.startTimeHour = st_hour;
			rb.startTimeMin = st_min;
			rb.endTimeHour = et_hour;
			rb.endTimeMin = et_min;
			rb.resourceID = rs.resourceID;
			
			return rb;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// containReservedCell
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 * 該当の ReserveBox が、既存の ReserveBox と重なっているかどうかを判断する処理
		 *  
		 * @param targetReserveBox
		 * @return 
		 */		
		protected function containReservedCell(targetReserveBox:ReserveBox, reserveBoxList:ArrayCollection):Boolean
		{
			for each (var rb:ReserveBox in reserveBoxList)
			{
				// visible=false なら現状、タイムテーブル上に載っていないボックスのはず、今後の処理は行わない。
				if(rb.visible == false)	continue;
				
				if(this.isCollided(rb, targetReserveBox))
				{
					// 一個でも重なっていたら true を返して終わり
					return true;
				}
			}
			
			//　全部falseだったら、falseを返して終わり。
			return false;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// iscollided
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function isCollided(rb1:ReserveBox, rb2:ReserveBox):Boolean
		{
			var ys1:int = rb1.positionIndex.y;
			var cc1:int = (rb1.cellCount == 0) ? 0 : (rb1.cellCount - 1);
			var ye1:int = rb1.positionIndex.y + cc1;
			var x1:int = rb1.positionIndex.x;

			var ys2:int = rb2.positionIndex.y;
			var cc2:int = (rb2.cellCount == 0) ? 0 : (rb2.cellCount - 1);
			var ye2:int = rb2.positionIndex.y + cc2;
			var x2:int = rb2.positionIndex.x;
			
			return isCollidedImpl(x1, ys1, ye1, x2, ys2, ye2);
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// isCollidedImpl
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function isCollidedImpl(x1:int, ys1:int, ye1:int, x2:int, ys2:int, ye2:int):Boolean
		{
			//まずは列がかぶっているか確認。
			if(x1 == x2)
			{
				//どこか重なっていれば即刻true
				if(ys1 == ys2 || ye1 == ye2 || ys1 == ye2 || ye1 == ys2 )
				{
					trace("isCollidedImpl 1");
					return true;
				}
				
				// rb1 が rb２より上にある場合
				if(ys1 < ys2)
				{
					//rb1のケツが、rb2の頭より下にあれば true
					if(ye1 > ys2)
					{
						trace("isCollidedImpl 2");
						return true;
					}
					
					//rb1のケツが、rb2のケツより下にあれば、rb2がrb1に隠れてしまっている状態と判断できる
					if(ye1 > ye2)
					{
						trace("isCollidedImpl 3");
						return true;
					}
				}
				// rb1 が rb2 より下にある場合
				else
				{
					//rb1の頭が、rb2のケツより上にあれば　true
					if(ye2 > ys1)
					{
						trace("isCollidedImpl 4");
						return true;
					}

					//rb2のケツが、rb1のケツより下にあれば、rb1がrb2に隠れてしまっている状態と判断できる
					if(ye1 < ye2)
					{
						trace("isCollidedImpl 5");
						return true;
					}
				}
			}
			
			// true がひとつもないことを確認して、false を返す。
			trace("isCollidedImpl 6");
			return false;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// getExtendCountBeyondTable
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		/**
		 *
		 * 予約ボックスが、タイムテーブルから下にはみ出しているセルの数を返す。
		 *  
		 * @param rb
		 * @return 
		 * 
		 */		
		private function getExtendCountBeyondTable(rb:ReserveBox):int
		{
			var rby:int = rb.positionIndex.y;
			var rcc:int = rb.cellCount;
			var rct:int = this.rowCnt - 2;	// rowcontはセルの数から、ヘッダー分２足されてるから引いてやる。

			var cnt:int = rby + rcc - rct;
			
			if(cnt > 0)
			{
				return cnt;
			}
			else
			{
				return 0;
			}
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// clearCurrentVar
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function clearCurrentVar():void
		{
			this.currentCellCnt = 0;
			this.currentMouseOnIdx = new Point();
			this.currentMouseOnPos = new Point();
			this.currentTargetReserveBox = null
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// getError
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function getError(id:String, name:String, message:String):Error
		{
			var error:Error = new Error(message,id);
			error.name = name;
			return error;
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// commonErrorHandler
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private function commonErrorHandler(error:Error):void
		{
			if(errorHandler != null)
			{
				errorHandler(error);
			}
			else
			{
				var msg:String = "";
				//msg += "[ErrorID : " + error.errorID + "]";
				msg += error.message;
				//msg += "StackTrace : ¥n" + error.getStackTrace() + "¥n";
				Alert.show(msg, error.name);
				
				trace(error.getStackTrace());
			}
		}
		
		private function setReserveBoxStyle(rb:ReserveBox):void
		{
			rb.setCustomStyle(	this.getStyle("reserveBoxFillColor"), 
				this.getStyle("reserveBoxAlpha"),
				this.getStyle("reserverNameTxtColor"),
				this.getStyle("reserveBoxBorderColor")
				);

		}
		
	}//end of class
}//end of package