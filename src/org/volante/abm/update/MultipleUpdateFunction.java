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


import java.util.Arrays;
import java.util.List;

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
 * This function does NOT do the proportional difference update indicated above. 
 * It checks if a neighbouring cell (Queen's case) is FR4 or FR5. If a neighbouring cell is not in one of these FRs
 * then the Capital value for the cell is set to 'change' 
 */
public class MultipleUpdateFunction implements CapitalUpdateFunction {
	Capital	capital		= null;
	@Attribute(required = false)
	double	top			= 1;
	@Attribute(required = false)
	double	bottom		= 0;
	@Attribute()
	double	change		= 0;
	@Attribute
	String	capitalName	= "";

	public MultipleUpdateFunction() {
	};

	public MultipleUpdateFunction(Capital c, double change) {
		this.capital = c;
		this.change = change;
	}

	public MultipleUpdateFunction(Capital c, double change, double top, double bottom) {
		this(c, change);
		this.top = top;
		this.bottom = bottom;
	}
	

	/**
	 * TODO This function did nothing. What should it do?
	 * 
	 * Applies the function to the cell. If you want to do something more complex (i.e. involving
	 * cell values) override this.
	 */
	@Override
	public void apply(Cell c, Region region, String year) {
		int x = c.getX();
		int y = c.getY();
		
		boolean Nnot = false;		//at least one of neighbours is non-nature 
		boolean AgI = false;
		boolean OAgI = false;
				
		//System.out.println(capital.getName());
		//System.out.println(c.getOwnersFrLabel());
		
		/** Soy Trap **/
		//Hard coding initialisation years in which we set agri cells to have debt == 5
		
		List<String> FixedDebtYears = Arrays.asList("2001","2018"); 
		
		if(FixedDebtYears.contains(year)){
			
			if(c.getOwnersFrLabel().equals("FR1")||c.getOwnersFrLabel().equals("FR2")||c.getOwnersFrLabel().equals("FR3")||c.getOwnersFrLabel().equals("FR6")){
				c.getOwner().setdebt(5);
			}
			else { c.getOwner().setdebt(0);}
		}
		
		//if not an initialisation year, decrease debt		
		if(!(FixedDebtYears.contains(year))){

			int trap = c.getOwner().getdebt();
			if(trap>0){  //if trap > 0, debt exists		
				c.getOwner().setdebt(trap-1);  //if debt exists, decrease by 1 (year)
			}
		}
		
		//debt is also updated in tryToComeIn in GiveUpGiveInAllocationModel.java (when a new agent converts a cell)
		//debt is checked in canTakeOver() in DefaultLandUseAgent.java  (to see if debt is low enough that change can occur)
				
		
		if(capital.getName().equals("OAgri Infrastructure")){
			
			DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
			
			if(!(baseCapitals.get(capital) == 1.0)){
				
				if(!(region.getCell(x, y-1)==null)){
					if(region.getCell(x, y-1).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
				if(!(region.getCell(x, y+1)==null)){
					if(region.getCell(x, y+1).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
				if(!(region.getCell(x-1, y)==null)){
					if(region.getCell(x-1, y).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
				if(!(region.getCell(x+1, y)==null)){
					if(region.getCell(x+1, y).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
				if(!(region.getCell(x+1, y+1)==null)){
					if(region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
				if(!(region.getCell(x-1, y+1)==null)){
					if(region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
				if(!(region.getCell(x+1, y-1)==null)){
					if(region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
				if(!(region.getCell(x-1, y-1)==null)){
					if(region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR6")) { OAgI = true; }
				}
			
			
				//if not OAgri (or Other) but neighbour is OAgri, set 0.75
				if(OAgI == true && (!c.getOwnersFrLabel().equals("FR6") && !c.getOwnersFrLabel().equals("FR7"))){
					//DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
					baseCapitals.put(capital, 0.95);			
					c.setBaseCapitals(baseCapitals);				
				}
				
			
				//if OAgri set 1
				if(c.getOwnersFrLabel().equals("FR6")){
					//DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
					baseCapitals.put(capital, 1);			
					c.setBaseCapitals(baseCapitals);				
				}
			}
			
			
			
			
			//System.out.println(capital.getName());
			//if(OAgI) { System.out.println("OAgI true"); }

		}
		
		
		
		if(capital.getName().equals("Agri Infrastructure")){
			
			DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
			
			if(!(baseCapitals.get(capital) == 1.0)){
			
				if(!(region.getCell(x, y-1)==null)){
					if(region.getCell(x, y-1).getOwnersFrLabel().equals("FR1")||region.getCell(x, y-1).getOwnersFrLabel().equals("FR2")||region.getCell(x, y-1).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}
				}
				if(!(region.getCell(x, y+1)==null)){
					if(region.getCell(x, y+1).getOwnersFrLabel().equals("FR1")||region.getCell(x, y+1).getOwnersFrLabel().equals("FR2")||region.getCell(x, y+1).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}
				}
				if(!(region.getCell(x-1, y)==null)){
					if(region.getCell(x-1, y).getOwnersFrLabel().equals("FR1")||region.getCell(x-1, y).getOwnersFrLabel().equals("FR2")||region.getCell(x-1, y).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}
				}
				if(!(region.getCell(x+1, y)==null)){
					if(region.getCell(x+1, y).getOwnersFrLabel().equals("FR1")||region.getCell(x+1, y).getOwnersFrLabel().equals("FR2")||region.getCell(x+1, y).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}
				}
				if(!(region.getCell(x+1, y+1)==null)){
					if(region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR1")||region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR2")||region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}
				}
				if(!(region.getCell(x-1, y+1)==null)){
					if(region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR1")||region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR2")||region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}
				}
				if(!(region.getCell(x+1, y-1)==null)){
					if(region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR1")||region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR2")||region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}			
				}
				if(!(region.getCell(x-1, y-1)==null)){
					if(region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR1")||region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR2")||region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR3")){
						AgI=true;
					}
				}	
				
				
				//if not Agri (or Other) but neighbour is agri, set 0.75
				if(AgI == true && (!c.getOwnersFrLabel().equals("FR1") && !c.getOwnersFrLabel().equals("FR2") && !c.getOwnersFrLabel().equals("FR3") && !c.getOwnersFrLabel().equals("FR7"))){
					//DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
					baseCapitals.put(capital, 0.95);			
					c.setBaseCapitals(baseCapitals);				
				}
				
				//if Agri set 1
				if(c.getOwnersFrLabel().equals("FR1") || c.getOwnersFrLabel().equals("FR2") || c.getOwnersFrLabel().equals("FR3")){
					//DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
					baseCapitals.put(capital, 1);			
					c.setBaseCapitals(baseCapitals);				
				}
			
			}
			
			//System.out.println(capital.getName());
			//if(AgI) { System.out.println("AgI true"); }

		}
		
		
		
		
		//use check on all non-nature FRs as below to avoid not picking up abandoned cells

		if(capital.getName().equals("Nature Access")){
			
			if(!(region.getCell(x, y-1)==null)){
				if(region.getCell(x, y-1).getOwnersFrLabel().equals("FR1") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR2") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x, y-1).getOwnersFrLabel().equals("FR6") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR7") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;
				}
			}
			if(!(region.getCell(x, y+1)==null)){
				if(region.getCell(x, y+1).getOwnersFrLabel().equals("FR1") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR2") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x, y+1).getOwnersFrLabel().equals("FR6") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR7") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;		
				}
			}
			if(!(region.getCell(x-1, y)==null)){
				if(region.getCell(x-1, y).getOwnersFrLabel().equals("FR1") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR2") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x-1, y).getOwnersFrLabel().equals("FR6") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR7") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x+1, y)==null)){
				if(region.getCell(x+1, y).getOwnersFrLabel().equals("FR1") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR2") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x+1, y).getOwnersFrLabel().equals("FR6") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR7") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x+1, y+1)==null)){
				if(region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR1") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR2") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR6") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR7") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x-1, y+1)==null)){
				if(region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR1") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR2") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR6") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR7") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x+1, y-1)==null)){
				if(region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR1") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR2") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR6") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR7") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x-1, y-1)==null)){
				if(region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR1") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR2") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR6") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR7") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}	
			
			double value = c.getBaseCapitals().getDouble(capital);

			if(c.getOwnersFrLabel().equals("FR4") || c.getOwnersFrLabel().equals("FR5")){
				if(Nnot == true) {
					value = 0.75; 
				} else	{  
					value = 0;					
				}				
			}
			
			if(!c.getOwnersFrLabel().equals("FR4") && !c.getOwnersFrLabel().equals("FR5")){
				value = 1;
			}
			
			DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
			baseCapitals.put(capital, value);			
			c.setBaseCapitals(baseCapitals);	
			
			//if(Nnot) { System.out.println("Nnot is true"); }
			
		}
	
		if(capital.getName().equals("Nature")){
			
			if(!(region.getCell(x, y-1)==null)){
				if(region.getCell(x, y-1).getOwnersFrLabel().equals("FR1") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR2") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x, y-1).getOwnersFrLabel().equals("FR6") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR7") || region.getCell(x, y-1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;
				}
			}
			if(!(region.getCell(x, y+1)==null)){
				if(region.getCell(x, y+1).getOwnersFrLabel().equals("FR1") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR2") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x, y+1).getOwnersFrLabel().equals("FR6") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR7") || region.getCell(x, y+1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;		
				}
			}
			if(!(region.getCell(x-1, y)==null)){
				if(region.getCell(x-1, y).getOwnersFrLabel().equals("FR1") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR2") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x-1, y).getOwnersFrLabel().equals("FR6") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR7") || region.getCell(x-1, y).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x+1, y)==null)){
				if(region.getCell(x+1, y).getOwnersFrLabel().equals("FR1") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR2") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x+1, y).getOwnersFrLabel().equals("FR6") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR7") || region.getCell(x+1, y).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x+1, y+1)==null)){
				if(region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR1") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR2") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR6") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR7") || region.getCell(x+1, y+1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x-1, y+1)==null)){
				if(region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR1") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR2") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR6") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR7") || region.getCell(x-1, y+1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x+1, y-1)==null)){
				if(region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR1") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR2") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR6") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR7") || region.getCell(x+1, y-1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}
			if(!(region.getCell(x-1, y-1)==null)){
				if(region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR1") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR2") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR3")
						|| region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR6") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR7") || region.getCell(x-1, y-1).getOwnersFrLabel().equals("FR8")){
					Nnot=true;				
				}
			}	
			

			double value = c.getBaseCapitals().getDouble(capital);
			
			if(c.getOwnersFrLabel().equals("FR4") || c.getOwnersFrLabel().equals("FR5")){				
				value = value + 0.01; //increase
				if(value>1){ value = 1; } //if the thus changed capital is now greater than 1, set it to 1
				
				if(Nnot == true) { value = 0.75; }  //if this Nature cell is at the edge, decrease 
			}
			
			if(c.getOwnersFrLabel().equals("FR1") || c.getOwnersFrLabel().equals("FR2") || c.getOwnersFrLabel().equals("FR3") || c.getOwnersFrLabel().equals("FR6") || c.getOwnersFrLabel().equals("FR7")){
				value = 0;
			}
			
			if(c.getOwnersFrLabel().equals("FR8")){
				value = 0.4;
			}

			DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
			baseCapitals.put(capital, value);			
			c.setBaseCapitals(baseCapitals);				
		}
		
		/*
		if(capital.getName().equals("Land Price")){
			
			double value = c.getBaseCapitals().getDouble(capital);
			
			//if(c.getOwnersFrLabel().equals("FR1") || c.getOwnersFrLabel().equals("FR2") || c.getOwnersFrLabel().equals("FR3") || c.getOwnersFrLabel().equals("FR6") || c.getOwnersFrLabel().equals("FR8")){
			//	value = value + 0.01;  //increase
			//	if(value>1){ value = 1; } //if the thus changed capital is now greater than 1, set it to 1
			//}
			
			if(c.getOwnersFrLabel().equals("FR4") || c.getOwnersFrLabel().equals("FR5")){
				
			//	value = value - c.getBaseCapitals().getDouble(c.g);
				
			}
			
						
			DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
			baseCapitals.put(capital, value);			
			c.setBaseCapitals(baseCapitals);	
		}	
		*/
		
		if(capital.getName().equals("Economic")){
			
			//if Agri or OAgri set 0.1
			if(c.getOwnersFrLabel().equals("FR1") || c.getOwnersFrLabel().equals("FR2") || c.getOwnersFrLabel().equals("FR3") || c.getOwnersFrLabel().equals("FR6")){
				
				DoubleMap<Capital>	baseCapitals		= (DoubleMap<Capital>) c.getBaseCapitals();
				baseCapitals.put(capital, 0.1);			
				c.setBaseCapitals(baseCapitals);
			}			
		}
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
			System.out.println("change>0");
			return value + (top - value) * change;
		}
		// e.g. bottom = 0.2, value = 0.6, change = -0.5 -> 0.6 - (0.2-0.6) * (-0.5) -> 0.6 -
		// (-0.4*-0.5) -> 0.4
		if (change < 0) {
			System.out.println("change<0");
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
		
	}
}