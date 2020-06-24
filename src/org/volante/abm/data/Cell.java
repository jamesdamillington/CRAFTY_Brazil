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
 * 
 */
package org.volante.abm.data;


import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import org.volante.abm.agent.Agent;
import org.volante.abm.agent.LandUseAgent;
import org.volante.abm.agent.property.PropertyId;
import org.volante.abm.agent.property.PropertyProvider;
import org.volante.abm.agent.property.PropertyProviderComp;
import org.volante.abm.schedule.RunInfo;
import org.volante.abm.serialization.Initialisable;

import com.moseph.modelutils.fastdata.DoubleMap;
import com.moseph.modelutils.fastdata.UnmodifiableNumberMap;


/**
 * A generic cell, with levels of baseCapitals, supply and demand for services and residual demand
 * 
 * A cell is can be owned by an agent, or by the null agent.
 * 
 * @author dmrust
 * 
 */
public class Cell implements Initialisable, PropertyProvider<Object> {
	private static final String	UNKNOWN				= "Unknown";			//$NON-NLS-1$

	/*
	 * Internal data
	 */
	DoubleMap<Capital>	baseCapitals		= null;				// Current levels of
																	// baseCapitals
	DoubleMap<Capital>			effectiveCapitals	= null;				// Current levels of
																			// effective capitals
																			// (including
																			// institutional
																			// effects)
	int offmap = 0;
	String prevFr = "LazyFR";

	// DoubleMap<Service> demand; //Current levels of spatialised demand
	DoubleMap<Service>	supply				= null;				// Current levels of spatialised
																	// supply
	// DoubleMap<Service> residual; //Residual demand
	LandUseAgent owner = Agent.NOT_MANAGED;
	Region				region				= null;
	String				id					= "";
	//String              countyid            ="";
	//String              stateid            ="";
	int					x					= 0;
	int					y					= 0;
	boolean				initialised			= false;

	Set<CellCapitalObserver> cellCapitalObservers = new HashSet<CellCapitalObserver>();

	PropertyProviderComp<Object> propertyProvider = null;


	public Cell() {
	}

	public Cell(int x, int y) {
		this.x = x;
		this.y = y;
		this.id = x + "," + y;
	}

	/*
	 * Initialisation
	 */
	@Override
	public void initialise(ModelData data, RunInfo info, Region region) {
		if (initialised) {
			return;
		}
		/*BufferedReader br;
		try {//read Cellinfo.csv and populate county and state id fields with data from this cell
			br = new BufferedReader(new FileReader("C:\\Users\\kkwj0949\\workspace\\CRAFTY_TemplateCoBRA\\data\\csv\\Cellinfo.csv"));
			String line = br.readLine();//remove top line of csv
			
			 while ((line = br.readLine()) != null) {
			    	
			       String[] Line = line.split(",");
			       
			       if(this.x==Integer.parseInt(Line[0])&&this.y==Integer.parseInt(Line[1])){
			    	   this.countyid=Line[3];
			    	   this.stateid =Line[2];
			    	   break;
			       }
			 }

			 br.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
		
		

		 
		this.region = region;
		initialised = true;
		baseCapitals = data.capitalMap();
		if (region.doesRequireEffectiveCapitalData()) {
			effectiveCapitals = data.capitalMap(); // Start with them being the same
		} else {
			effectiveCapitals = baseCapitals; // no need to duplicate base
												// capitals
		}
		supply = data.serviceMap();
	}

	public UnmodifiableNumberMap<Capital> getEffectiveCapitals() {
		return effectiveCapitals;
	}

	public UnmodifiableNumberMap<Capital> getBaseCapitals() {
		return baseCapitals;
	}

	public void setBaseCapitals(UnmodifiableNumberMap<Capital> c) {
		if (baseCapitals == effectiveCapitals) {
			for (CellCapitalObserver observer : this.cellCapitalObservers) {
				observer.cellCapitalChanged(this, true);
			}
		}

		baseCapitals.copyFrom(c);
		if (baseCapitals == effectiveCapitals) {
			for (CellCapitalObserver observer : this.cellCapitalObservers) {
				observer.cellCapitalChanged(this, false);
			}
		}
	}

	/**
	 * NOTE: When using this method, call {@link Region#setRequiresEffectiveCapitalData()}!
	 * 
	 * @param c
	 */
	public void setEffectiveCapitals(UnmodifiableNumberMap<Capital> c) {
		if (region.doesRequireEffectiveCapitalData() && baseCapitals == effectiveCapitals) {
			effectiveCapitals = region.data.capitalMap();
		}

		// notify observers:
		for (CellCapitalObserver observer : this.cellCapitalObservers) {
			observer.cellCapitalChanged(this, true);
		}

		effectiveCapitals.copyFrom(c);

		// notify observers:
		for (CellCapitalObserver observer : this.cellCapitalObservers) {
			observer.cellCapitalChanged(this, false);
		}
	}

	public void initEffectiveCapitals() {
		effectiveCapitals.copyFrom(baseCapitals);
	}

	/*
	 * Ownership
	 */
	public LandUseAgent getOwner() {
		return owner;
	}

	public void setOwner(LandUseAgent o) {
		owner = o;
	}
	public void setprevFR(String o) {
		this.prevFr = o;
	}
	
	public String getprevFR(){
		return this.prevFr;
	}

	public int getOwnersFrSerialID() {
		return (owner == null) ? -1 : owner.getFC().getFR().getSerialID();
	}

	public String getOwnersFrLabel() {
		return (owner == null) ? "None" : owner.getFC().getFR().getLabel();
	}

	/*
	 * Supply and demand
	 */
	public void setSupply(UnmodifiableNumberMap<Service> s) {
		supply.copyFrom(s);
	}

	public UnmodifiableNumberMap<Service> getSupply() {
		return supply;
	}

	/**
	 * Allows for updating of the cell's supply without creating intermediate
	 * maps
	 * 
	 * @return map of modifiable supply
	 */
	public DoubleMap<Service> getModifiableSupply() {
		return supply;
	}

	@Override
	public String toString() {
		if (!id.equals("")) {
			return id;
		}
		return super.toString();
	}

	public void resetSupply() {
		supply.clear();
	}

	public int getX() {
		return x;
	}

	public int getY() {
		return y;
	}
	
	public String getRegionID() {
		if (region == null) {
			return UNKNOWN;
		}
		
		return region.getID();
	}
/*	public String getcountyID() {
		if (this.countyid == null) {
			return UNKNOWN;
		}
		
		return this.countyid;
	}
	public String getstateID() {
		if (this.stateid == null) {
			return UNKNOWN;
		}
		
		return this.stateid;
	}*/
	public Region getRegion() {
		return region;
	}

	public boolean isInitialised() {
		return initialised;
	}

	public void registerCellCapitalObserver(CellCapitalObserver observer) {
		this.cellCapitalObservers.add(observer);
	}

	public void removeCellCapitalObserver(CellCapitalObserver observer) {
		this.cellCapitalObservers.remove(observer);
	}

	/**
	 * @see org.volante.abm.agent.property.DoublePropertyProvider#isProvided(org.volante.abm.agent.property.PropertyId)
	 */
	@Override
	public boolean isProvided(PropertyId property) {
		if (this.propertyProvider != null) {
			return this.propertyProvider.isProvided(property);
		} else {
			return false;
		}
	}

	/**
	 * @see org.volante.abm.agent.property.DoublePropertyProvider#getProperty(org.volante.abm.agent.property.PropertyId)
	 */
	@Override
	public Object getObjectProperty(PropertyId property) {
		if (this.propertyProvider != null) {
			return this.propertyProvider.getObjectProperty(property);
		} else {
			throw new IllegalStateException("There is not property provided initialised!");
		}
	}

	/**
	 * @see org.volante.abm.agent.property.PropertyProvider#setProperty(org.volante.abm.agent.property.PropertyId,
	 *      java.lang.Object)
	 */
	@Override
	public void setObjectProperty(PropertyId propertyId, Object value) {
		if (this.propertyProvider == null) {
			this.propertyProvider = new PropertyProviderComp<>();
		}
		this.propertyProvider.setObjectProperty(propertyId, value);
	}
}
