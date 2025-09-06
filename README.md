# UFMC-Transceiver-Design-in-MATLAB  

Based on the theoretical model of Universal Filtered Multi-Carrier (UFMC) modulation, this project uses MATLAB to implement and simulate a complete *UFMC transceiver system* (transmitter + channel + receiver).  

## Objective  
- Comprehend and simulate the *UFMC transceiver system*.  
- Analyze the end-to-end transmission process including filtering, modulation, and demodulation.  
- Visualize the *time domain* and *frequency domain* properties of the UFMC signal.  
- Evaluate Bit Error Rate (BER) performance under AWGN and multipath fading channels.  
- Study the impact of system parameters such as IFFT size, filter length, number of subbands, and SNR.  

##  UFMC Transceiver Workflow  

### **Transmitter (TX)**  
1. Generate *input data bits* for each subband.  
2. Perform *QAM/PSK modulation* (e.g., 16-QAM).  
3. Apply *Serial-to-Parallel conversion* for IFFT processing.  
4. Compute *N-point IFFT* → time-domain conversion.  
5. Apply *Subband FIR filtering* (prototype filter).  
6. Sum filtered subbands → Final UFMC transmit signal.  

### **Channel**  
- **AWGN only**, or  
- **AWGN + Multipath fading** (configurable).  

### **Receiver (RX)**  
1. Perform *Subband filtering* using the matched FIR filter.  
2. Apply *Block synchronization* and *FFT demodulation*.  
3. Extract subbands from FFT output.  
4. Apply *Equalization* (ideal zero-forcing with known channel).  
5. Perform *QAM Demodulation* to recover transmitted bits.  
6. Calculate *Bit Error Rate (BER)*.
7. 
## Implementation (MATLAB)  
- **Language:** MATLAB  
- **Key functions used:** `qammod`, `qamdemod`, `ifft`, `fft`, `conv`, `fir1`, `fftshift`  

The code simulates:  
- Random input bit generation.  
- QAM mapping and subband processing.  
- UFMC signal generation with filtering.  
- Transmission over AWGN/multipath channel.  
- Receiver chain with filtering, FFT, equalization, demodulation.  
- BER evaluation.  

**Main script:** `ufmc_transceiver.m`  

## Simulation Results  
The script generates multiple plots:  
1. UFMC Signal in Time Domain  
2. UFMC Signal Spectrum (Frequency Domain)  
3. Prototype Filter Frequency Response  
4. Received Constellation Diagram  

**Numerical results:**  
- Bit Error Rate (BER) under various SNR and channel conditions.  

**Parameter effects:**  
- *IFFT size* → Larger size improves frequency resolution.  
- *Filter length* → Longer filters provide better subband isolation but increase complexity.  
- *Number of subbands* → More subbands give denser spectra but higher processing load.  
- *SNR* → Higher SNR improves BER performance. 

##  Discussion  
- UFMC removes the need for a cyclic prefix (as in OFDM) while maintaining lower complexity than FBMC.  
- Simulation results confirm theoretical advantages in spectral localization.  
- BER performance depends on filter design, IFFT size, and equalization.  
- Framework can be extended to compare UFMC with OFDM and FBMC in future work.  

---
