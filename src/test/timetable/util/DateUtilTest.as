package test.timetable.util
{
	import flexunit.framework.Assert;
	
	import muit.timetable.util.DateUtil;
	
	import mx.charts.chartClasses.DataDescription;
	import mx.collections.ArrayCollection;
	
	public class DateUtilTest
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testBe2char():void
		{
			Assert.assertEquals(DateUtil.be2char("0"),"00");
			Assert.assertEquals(DateUtil.be2char("1"),"01");
			Assert.assertEquals(DateUtil.be2char("23"),"23");
			Assert.assertEquals(DateUtil.be2char("02"),"02");
			Assert.assertEquals(DateUtil.be2char("123"),"123");
			Assert.assertEquals(DateUtil.be2char(""),"");
		}
		
		[Test]
		public function testDate1GreaterThanDate2():void
		{
			Assert.assertTrue(DateUtil.date1GreaterThanDate2(new Date(2011,3,3), new Date(2011,3,2)));
			Assert.assertTrue(DateUtil.date1GreaterThanDate2(new Date(2011,3,3,1,0), new Date(2011,3,1,23,0)));
			Assert.assertFalse(DateUtil.date1GreaterThanDate2(new Date(2011,3,1), new Date(2011,3,3)));
			Assert.assertFalse(DateUtil.date1GreaterThanDate2(new Date(2011,3,1,23,0), new Date(2011,3,3,1,0)));
			Assert.assertFalse(DateUtil.date1GreaterThanDate2(new Date(2011,3,3), new Date(2011,3,3)));
			Assert.assertFalse(DateUtil.date1GreaterThanDate2(new Date(2011,3,3,23,0), new Date(2011,3,3,1,0)));
		}

		[Test]
		public function testDate1GreaterThanOrEqualDate2():void
		{
			Assert.assertTrue(DateUtil.date1GreaterThanOrEqualDate2(new Date(2011,3,3), new Date(2011,3,2)));
			Assert.assertTrue(DateUtil.date1GreaterThanOrEqualDate2(new Date(2011,3,3,1,0), new Date(2011,3,1,23,0)));
			Assert.assertFalse(DateUtil.date1GreaterThanOrEqualDate2(new Date(2011,3,1), new Date(2011,3,3)));
			Assert.assertFalse(DateUtil.date1GreaterThanOrEqualDate2(new Date(2011,3,1,23,0), new Date(2011,3,3,1,0)));
			Assert.assertTrue(DateUtil.date1GreaterThanOrEqualDate2(new Date(2011,3,3), new Date(2011,3,3)));
			Assert.assertTrue(DateUtil.date1GreaterThanOrEqualDate2(new Date(2011,3,3,23,0), new Date(2011,3,3,1,0)));
		}
		
		[Test]
		public function testDate1LessThanDate2():void
		{
			Assert.assertFalse(DateUtil.date1LessThanDate2(new Date(2011,3,3), new Date(2011,3,2)));
			Assert.assertFalse(DateUtil.date1LessThanDate2(new Date(2011,3,3,1,0), new Date(2011,3,1,23,0)));
			Assert.assertTrue(DateUtil.date1LessThanDate2(new Date(2011,3,1), new Date(2011,3,3)));
			Assert.assertTrue(DateUtil.date1LessThanDate2(new Date(2011,3,1,23,0), new Date(2011,3,3,1,0)));
			Assert.assertFalse(DateUtil.date1LessThanDate2(new Date(2011,3,3), new Date(2011,3,3)));
			Assert.assertFalse(DateUtil.date1LessThanDate2(new Date(2011,3,3,23,0), new Date(2011,3,3,1,0)));
		}
		
		[Test]
		public function testDate1LessThanOrEqualDate2():void
		{
			Assert.assertFalse(DateUtil.date1LessThanOrEqualDate2(new Date(2011,3,3), new Date(2011,3,2)));
			Assert.assertFalse(DateUtil.date1LessThanOrEqualDate2(new Date(2011,3,3,1,0), new Date(2011,3,1,23,0)));
			Assert.assertTrue(DateUtil.date1LessThanOrEqualDate2(new Date(2011,3,1), new Date(2011,3,3)));
			Assert.assertTrue(DateUtil.date1LessThanOrEqualDate2(new Date(2011,3,1,23,0), new Date(2011,3,3,1,0)));
			Assert.assertTrue(DateUtil.date1LessThanOrEqualDate2(new Date(2011,3,3), new Date(2011,3,3)));
			Assert.assertTrue(DateUtil.date1LessThanOrEqualDate2(new Date(2011,3,3,23,0), new Date(2011,3,3,1,0)));
		}
		
		[Test]
		public function testEqual():void
		{
			Assert.assertFalse(DateUtil.equal(new Date(2011,3,3), new Date(2011,3,2)));
			Assert.assertFalse(DateUtil.equal(new Date(2011,3,3,1,0), new Date(2011,3,1,23,0)));
			Assert.assertFalse(DateUtil.equal(new Date(2011,3,1), new Date(2011,3,3)));
			Assert.assertFalse(DateUtil.equal(new Date(2011,3,1,23,0), new Date(2011,3,3,1,0)));
			Assert.assertTrue(DateUtil.equal(new Date(2011,3,3), new Date(2011,3,3)));
			Assert.assertTrue(DateUtil.equal(new Date(2011,3,3,23,0), new Date(2011,3,3,1,0)));
		}
		
		[Test]
		public function testPlusDay():void
		{
			Assert.assertEquals(DateUtil.plusDay(new Date(2011,3,3), 1).getTime(), new Date(2011,3,4).getTime());		//普通のパターン
			Assert.assertEquals(DateUtil.plusDay(new Date(2011,3,3,12), 2).getTime(), new Date(2011,3,5,12).getTime());	//２日追加パターン
			Assert.assertEquals(DateUtil.plusDay(new Date(2011,0,1), 31).getTime(), new Date(2011,1,1).getTime());		//３０日追加パターン
			Assert.assertEquals(DateUtil.plusDay(new Date(2011,3,30), 1).getTime(), new Date(2011,4,1).getTime());		//月越しパターン
			Assert.assertEquals(DateUtil.plusDay(new Date(2011,1,28), 1).getTime(), new Date(2011,2,1).getTime());		//２月から３月パターン
			Assert.assertEquals(DateUtil.plusDay(new Date(2012,1,28), 1).getTime(), new Date(2012,1,29).getTime());		//２月から３月閏年パターン
			Assert.assertEquals(DateUtil.plusDay(new Date(2011,11,31), 1).getTime(), new Date(2012,0,1).getTime());		//年越しパターン
		}
		
		[Test]
		public function testGetDaysLength_1():void
		{
			Assert.assertEquals(1, DateUtil.getDaysLength(new Date(2011,4,1), new Date(2011,4,1)));
		}
		
		[Test]
		public function testGetDaysLength_2():void
		{
			Assert.assertEquals(2, DateUtil.getDaysLength(new Date(2011,4,1), new Date(2011,4,2)));
		}
		
		[Test]
		public function testGetDaysLength_3():void
		{
			Assert.assertEquals(3, DateUtil.getDaysLength(new Date(2011,4,1), new Date(2011,4,3)));
		}
		
		[Test]
		public function testGetDaysLength_4():void
		{
			Assert.assertEquals(2, DateUtil.getDaysLength(new Date(2011,2,31), new Date(2011,3,1)));
		}
		
		[Test]
		public function testGetDaysLength_5():void
		{
			Assert.assertEquals(2, DateUtil.getDaysLength(new Date(2010,11,31), new Date(2011,0,1)));
		}
		
		[Test]
		public function testSortByDate_1():void
		{
			var targets:ArrayCollection = new ArrayCollection();
			targets.addItem(new Date(2011,3,25));
			targets.addItem(new Date(2011,3,23));
			targets.addItem(new Date(2011,3,24));
			
			var valids:ArrayCollection = new ArrayCollection();
			valids.addItem(new Date(2011,3,23));
			valids.addItem(new Date(2011,3,24));
			valids.addItem(new Date(2011,3,25));
			
			Assert.assertTrue(this.isValidSort(targets, valids));
		}
		
		[Test]
		public function testSortByDate_2():void
		{
			var targets:ArrayCollection = new ArrayCollection();
			targets.addItem(new Date(2011,3,25));
			targets.addItem(new Date(2011,3,24));
			targets.addItem(new Date(2011,3,23));
			
			var valids:ArrayCollection = new ArrayCollection();
			valids.addItem(new Date(2011,3,23));
			valids.addItem(new Date(2011,3,24));
			valids.addItem(new Date(2011,3,25));
			
			Assert.assertTrue(this.isValidSort(targets, valids));
		}

		
		private function isValidSort(targets:ArrayCollection, valids:ArrayCollection):Boolean
		{
			var sorted:ArrayCollection = DateUtil.sortByDate(targets);
			
			if(sorted.length != valids.length) return false;
			
			var len:int = sorted.length;
			for(var i:int=0; i<len; i++)
			{
				var s:Date = sorted.getItemAt(i) as Date;
				var v:Date = valids.getItemAt(i) as Date;
				if(s.getTime() != v.getTime())
				{
					return false;
				}
			}
			
			return true;
		}

	}
}