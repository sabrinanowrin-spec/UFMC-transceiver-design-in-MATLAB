# UFMC-transceiver-design-in-MATLAB 

This project implements and simulates a *UFMC transmitter system* in MATLAB, based on the theoretical model of Universal Filtered Multi-Carrier modulation. UFMC is a modern multi-carrier modulation technique developed to overcome the shortcomings of *OFDM* (Orthogonal Frequency Division Multiplexing) and *FBMC* (Filter Bank Multi-Carrier).  

---

## Objective
- Understand and simulate the *UFMC transmitter system*.  
- Compare UFMC with OFDM and FBMC.  
- Visualize UFMC signal characteristics in both *time domain* and *frequency domain*.  
- Study the effect of system parameters (IFFT size, filter length, number of subbands).  

---

## 📖 Theory
- *OFDM*: Subcarriers are orthogonal, bandwidth-efficient, but require a cyclic prefix (reduces spectral efficiency).  
- *FBMC*: Each subcarrier is individually filtered, eliminating the cyclic prefix but increasing complexity.  
- *UFMC*:  
  - Divides the spectrum into *subbands* (each with multiple subcarriers).  
  - Applies *filtering at subband level* (not individual subcarriers).  
  - No cyclic prefix required.  
  - Provides better spectral efficiency and lower out-of-band emissions.  

---

## ⚙ UFMC Transmitter Steps
1. *Input data bits* per subband.  
2. *Modulation* using QAM/PSK (e.g., 16-QAM).  
3. *Serial-to-Parallel conversion* for IFFT processing.  
4. *N-point IFFT* → Converts to time-domain.  
5. *Parallel-to-Serial conversion*.  
6. *Subband filtering* using FIR filters.  
7. *Summation* of filtered subbands → Final UFMC signal.  

---

## 🛠 Implementation (MATLAB)
- Language: *MATLAB*  
- Key functions used: qammod, ifft, conv, fir1, fftshift  
- Code simulates:
  - Random input bit generation.  
  - QAM symbol mapping.  
  - UFMC subband processing with IFFT + filtering.  
  - Time & frequency domain analysis.  

📂 Main script: ufmc_transmitter.m  

---

## 📊 Simulation Results
The script generates three plots:
1. *UFMC Signal in Time Domain*  
2. *UFMC Signal Spectrum (Frequency Domain)*  
3. *Filtered Output of First Subband*  

Additionally, effects of varying parameters were studied:
- *IFFT size* → Larger size improves frequency resolution.  
- *Filter length* → Longer filters provide better subband isolation but increase complexity.  
- *Number of subbands* → More subbands give denser spectra but higher complexity.  

---

## 📝 Discussion
- UFMC successfully addresses OFDM’s cyclic prefix overhead and FBMC’s high complexity.  
- The MATLAB simulation matches theoretical expectations.  
- Parameter tuning (e.g., filter length, IFFT size) directly impacts spectral characteristics.  

---

## ✅ Conclusion
- Implemented and simulated a *UFMC transmitter system* in MATLAB.  
- Verified theoretical concepts through practical simulation.  
- Studied the impact of different parameters on UFMC performance.  

---

## 📚 References
- [OFDM Basics – GeeksforGeeks](https://www.geeksforgeeks.org/orthogonal-frequency-division-multiplexing-ofdm/)  
- [OFDM Explanation – LinkedIn Article](https://www.linkedin.com/pulse/ofdm-orthogonal-frequency-division-multiplexing-fpgas-juan-abelaira)  
- [Research Article on UFMC – Springer](https://link.springer.com/chapter/10.1007/978-981-16-6624-7_35)  
- [YouTube: OFDM vs UFMC](https://www.youtube.com/watch?v=zhMST8bX_fY)  
- [MathWorks: UFMC vs OFDM](https://www.mathworks.com/help/comm/ug/ufmc-vs-ofdm-modulation.html)  

