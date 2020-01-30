import java.util.Comparator;

public class LSCComparator implements Comparator{

	public int compare(Object _p1, Object _p2) {
		// TODO Auto-generated method stub
		DataPoint p1 = (DataPoint)_p1;
		DataPoint p2 = (DataPoint)_p2;
		if(p1.localSparsityCoefficient > p2.localSparsityCoefficient)
		{
			return -1;
		}
		else if(p1.localSparsityCoefficient == p2.localSparsityCoefficient)
		{
			return 0;
		}
		else //p1.localOutlierFactor < p2.localOutlierFactor
		{
			return 1;
		}

	}
	
}