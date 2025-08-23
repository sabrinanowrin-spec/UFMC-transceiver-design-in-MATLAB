# UFMC-transceiver-design-in-MATLAB 
Based on the theoretical model of Universal Filtered Multi-Carrier modulation, this project uses MATLAB to implement and simulate a *UFMC transmitter system*.
## Objective
- comprehend and simulate the *UFMC transmitter system*.  
- Examine UFMC in comparison to OFDM and FBMC.  
- Visualize the *time domain* and *frequency domain* properties of the UFMC signal.  
- Study the impact of system parameters such as IFFT size, filter length, number of subbands.
- 

## UFMC Transmitter Steps
1. *Input data bits* for each subband.  
2. QPM/PSK *Modulation* (e.g., 16-QAM).  
3. *Serial-to-Parallel conversion* for IFFT processing.  
4. *N-point IFFT* → time-domain conversion.  
5. Conversion from *Parallel-to-Serial*.  
6. FIR filtersfor *Subband filtering*.  
7. *Summation* of filtered subbands → Final UFMC signal.   

## Implementation (MATLAB)
- Language: *MATLAB*  
- Key functions used: qammod, ifft, conv, fir1, fftshift  
- Code simulates:
  - Random input bit generation.  
  - QAM symbol mapping.  
  - UFMC subband processing with IFFT + filtering.  
  - Time & frequency domain analysis.  

 Main script: ufmc_transmitter.m  

## Simulation Results
The script generates three plots:
1. *UFMC Signal in Time Domain*  
2. *UFMC Signal Spectrum (Frequency Domain)*  
3. *Filtered Output of First Subband*  

Additionally, effects of varying parameters were studied:
- *IFFT size* → Larger size improves frequency resolution.  
- *Filter length* → Longer filters provide better subband isolation but increase complexity.  
- *Number of subbands* → More subbands give denser spectra but higher complexity.  


## Discussion
- UFMC successfully addresses OFDM’s cyclic prefix overhead and FBMC’s high complexity.  
- The MATLAB simulation matches theoretical expectations.  
- Parameter tuning (e.g., filter length, IFFT size) directly impacts spectral characteristics.  


