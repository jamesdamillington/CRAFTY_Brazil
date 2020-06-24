/**
 * This file is part of
 * 
 * CRAFTY - Competition for Resources between Agent Functional TYpes
 *
 * Copyright (C) 2014 School of GeoScience, University of Edinburgh, Edinburgh, UK
 * 
 * CRAFTY is free software: You can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software 
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *  
 * CRAFTY is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * School of Geoscience, University of Edinburgh, Edinburgh, UK
 */
package org.volante.abm.update;


import java.awt.List;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Scanner;

import org.simpleframework.xml.Attribute;
import org.volante.abm.data.Capital;
import org.volante.abm.data.Cell;
import org.volante.abm.data.ModelData;
import org.volante.abm.data.Region;
import org.volante.abm.schedule.RunInfo;
import org.volante.abm.update.AgentTypeUpdater.CapitalUpdateFunction;

import com.moseph.modelutils.fastdata.DoubleMap;


/**
 * Expresses change of value as a proportion of difference with top value (for +ve numbers) or
 * bottom value (for -ve numbers)
 * 
 * @author dmrust
 * 
 */
public class SoyChangeFunction implements CapitalUpdateFunction {
	Capital	capital		= null;
	@Attribute(required = false)
	double	top			= 1;
	@Attribute(required = false)
	double	bottom		= 0;
	@Attribute(required = false)
	double	top2			= 1;
	@Attribute(required = false)
	double	bottom2		= 0;
	@Attribute()
	double	change		= 0;
	@Attribute()
	double	perfect		= 0;
	@Attribute()
	double	perfect2		= 0;
	@Attribute
	String	capitalName	= "";
	ArrayList<String[]> Soilquality = new ArrayList<String[]>();
	double temperature = 0;
	double precipitation = 0;
	
	

	public SoyChangeFunction() {
	};

	public SoyChangeFunction(Capital c, double change) {
		this.capital = c;
		this.change = change;
	}

	public SoyChangeFunction(Capital c, double change, double top, double bottom) {
		this(c, change);
		this.top = top;
		this.bottom = bottom;
	}

	/**
	 * TODO This function did nothing. What should it do?
	 * 
	 * Applies the function to the cell. If you want to do something more complex (i.e. involving
	 * cell values) override this.
	 * @throws IOException 
	 */
	@Override
	public void apply(Cell c, Region region, String year) throws IOException {
		
		   // System.out.println(c.getOwnersFrLabel());   
		String xcoor = ""+c.getX();
		//System.out.println("X"+xcoor);
		String ycoor = ""+c.getY();
		
		
		//System.out.println("Y"+ycoor);
		int i =0;
		
		/*for(i=0; i<Soilquality.size(); i++){ //removed code to do with updating soil quality every tic
			
			if(Soilquality.get(i)[0].equals(xcoor)&&Soilquality.get(i)[1].equals(ycoor)){
				//System.out.println("soilquality x"+Soilquality.get(i)[0]+" and soilquality y"+Soilquality.get(i)[1]);
				//System.out.println("soilqualityb4"+Soilquality.get(i)[2]);
					Soilquality.get(i)[2] = ""+(Double.parseDouble(Soilquality.get(i)[2])+change);//update soil quality based on specified change
					//System.out.println("soilqualityafter"+Soilquality.get(i)[2]);
					break;
			}
		}*/
		
		
		BufferedReader tr = new BufferedReader(new FileReader("C:\\Users\\k1076631\\craftyworkspace\\CRAFTY_TemplateCoBRA\\data\\csv\\Update"+year+".csv"));
		String line=tr.readLine();//remove top line of csv
		
		 while ((line = tr.readLine()) != null) {
			 
		       String[] Line = line.split(",");
		       if(Line[0].equals(xcoor)&&Line[1].equals(ycoor)){
		    	  // System.out.println("tempb4"+temperature);
		    	   temperature = Double.parseDouble(Line[3]);
		    	   precipitation = Double.parseDouble(Line[2]);
		    	 //  System.out.println("tempafter"+temperature);
		    	   break;
		       }
		 }
		 tr.close();
		 
		
		int cropfailure = 1;
		if(temperature>top||temperature<bottom||precipitation>top2||precipitation<bottom2){
		//	System.out.println("top1"+top);
			//System.out.println("top2"+top2);
			//System.out.println("bottom1"+bottom);
		//	System.out.println("bottom2"+bottom2);
			cropfailure = 0;
		}
	//	System.out.println("cropfailure"+cropfailure);
		//System.out.println("soilquality"+Soilquality.get(i)[2]);
	//	System.out.println("perfect"+perfect);
	//	System.out.println("perfect2"+perfect2);
	//	System.out.println("temperature"+temperature);
	//	System.out.println("prec"+precipitation);
	//	System.out.println("1-Math.abs(perfect-temperature)"+(1-Math.abs(perfect-temperature)));
	//	System.out.println("1-Math.abs(perfect2-precipitation)"+(1-Math.abs(perfect2-precipitation)));
		double value = Double.parseDouble(Soilquality.get(i)[2])*(1-Math.abs(perfect-temperature))*(1-Math.abs(perfect2-precipitation))*cropfailure;
	//	System.out.println("value"+value);
		DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
		baseCapitals.put(capital, value);
		
		c.setBaseCapitals(baseCapitals);
		
		//new java.util.Scanner(System.in).nextLine();
	}

	/**
	 * The actual update function. If you want to change the calculation, override this.
	 * 
	 * @param value
	 * @return
	 */
	public double function(double value) {
		// e.g. top = 0.8, value = 0.4, change = 0.5 -> 0.4 + (0.8-0.4)*0.5 -> 0.6
		System.out.println("funcinit");
		if (change > 0) {
	//		System.out.println("change>0");
			return value + (top - value) * change;
		}
		// e.g. bottom = 0.2, value = 0.6, change = -0.5 -> 0.6 - (0.2-0.6) * (-0.5) -> 0.6 -
		// (-0.4*-0.5) -> 0.4
		if (change < 0) {
	//		System.out.println("change<0");
			return value - (bottom - value) * change;
		}
		System.exit(0);
		return value;
	}

	@Override
	public void initialise(ModelData data, RunInfo info, Region extent) throws Exception {
		
		
		if (capital == null) {
			capital = data.capitals.forName(capitalName);
		}
		BufferedReader br = new BufferedReader(new FileReader("C:\\Users\\k1076631\\craftyworkspace\\CRAFTY_TemplateCoBRA\\data\\csv\\Update2000.csv"));
		String line = br.readLine();//remove top line of csv
		
		 while ((line = br.readLine()) != null) {
		    	
		       String[] Line = line.split(",");
		       String[] Line2 = {Line[0],Line[1],Line[4]};
		       
		       Soilquality.add(Line2);
		 }
		 
		 br.close();
		
	}
}