//=============================================================================================================
/**
* @file     rapmusic_cuda.cu
* @author   Christoph Dinh <christoph.dinh@live.de>;
* @version  1.0
* @date     March, 2011
*
* @section  LICENSE
*
* Copyright (C) 2011 Christoph Dinh. All rights reserved.
*
* No part of this program may be photocopied, reproduced,
* or translated to another program language without the
* prior written consent of the author.
*
*
* @brief    ToDo Documentation...
*
*/


//*************************************************************************************************************
//=============================================================================================================
// CUDA INCLUDES
//=============================================================================================================

#include "../include/rapmusic_cuda.cuh"

#include "../include/cudadevice.cuh"
#include "../include/handle_error.cuh"
#include "../include/rapmusic_kernel.cuh"

#include "../include/cuhpcvalue.cuh"


//*************************************************************************************************************
//=============================================================================================================
// CPP INCLUDES
//=============================================================================================================


#include "../../cpp/include/eigeninterface.h"

#include "../../cpp/include/model.h"

#include "../../cpp/include/rapdipoles.h"


//*************************************************************************************************************
//=============================================================================================================
// DEFINE NAMESPACE HPCLib
//=============================================================================================================

namespace HPCLib
{

//*************************************************************************************************************
//=============================================================================================================
// USED NAMESPACES
//=============================================================================================================


//*************************************************************************************************************
//=============================================================================================================
// DEFINE MEMBER METHODS
//=============================================================================================================

RapMusic_Cuda::RapMusic_Cuda()
: m_iPairCols(6)
, m_iMaxBlocksPerMultiProcessor(8) //CUDA C Programming Guide - Appendix F
{

}


//*************************************************************************************************************

RapMusic_Cuda::~RapMusic_Cuda()
{
    m_host_pLeadFieldMat = NULL;

    //garbage collecting
    //######## CUDA START ########
        // free the memory allocated on the GPU
        /*HANDLE_ERROR( cudaFree( m_dev_pLeadFieldMat ) );*/
        delete m_dev_pLeadFieldMat;

        delete m_dev_pVecPairIdxCombinations;
    //######## CUDA END ########
}


//*************************************************************************************************************

//template <class T>
bool RapMusic_Cuda::initRAPMusic(   HPCLib::CudaDevice* p_pDeviceInfo,
                                    HPCLib::Model<float>* p_pModel,
                                    bool p_bSparsed, int p_iN, double p_dThr)
{
    return initRAPMusic(p_pDeviceInfo,
                        p_bSparsed ? p_pModel->getSparsedLeadFieldMat() : p_pModel->getLeadFieldMat(),
                        p_bSparsed ? p_pModel->getSparsedGridMat() : p_pModel->getGridMat(),
                        p_iN, p_dThr);
}


//*************************************************************************************************************

//template <class T>
bool RapMusic_Cuda::initRAPMusic(   HPCLib::CudaDevice* p_pDeviceInfo,
                                    HPCMatrix<float>* p_pMatLeadField,
                                    HPCMatrix<float>* p_pMatGrid,
                                    int p_iN, double p_dThr)
{
    m_iMultiProcessorCount = p_pDeviceInfo->getSelectedDeviceProperties().multiProcessorCount;//14;
    m_iWarpSize = p_pDeviceInfo->getSelectedDeviceProperties().warpSize;//32;
    m_iMaxThreadsPerMultiProcessor =  p_pDeviceInfo->getSelectedDeviceProperties().maxThreadsPerMultiProcessor;//1536;
    m_iSharedMemoryPerMultiProcessor = p_pDeviceInfo->getSelectedDeviceProperties().sharedMemPerBlock;//48*1024;

    cublasStatus status = cublasInit ();

    //Initialize RAP-MUSIC
    std::cout << "##### Initialization CUDA RAP MUSIC started ######\n\n";

    m_iN = p_iN;
    m_dThreshold = p_dThr;

    //Grid check
    if(p_pMatGrid != NULL)
    {
        if ( p_pMatGrid->rows() != p_pMatLeadField->cols() / 3 )
        {
            std::cout << "Grid does not fit to given Lead Field!\n";
            return false;
        }
    }

    m_pMatGrid = p_pMatGrid;

    //Lead Fiel check
    if ( p_pMatLeadField->cols() % 3 != 0 )
    {
        std::cout << "Lead Field is not associated with a 3D grid!\n";
        return false;
    }

    m_pMatLeadField = p_pMatLeadField;

    m_dev_pLeadFieldMat = new cuHPCMatrix<float>(*p_pMatLeadField);//### CUDA ###

    m_iNumGridPoints = (int)(m_dev_pLeadFieldMat->cols()/3);
    m_iNumChannels = m_dev_pLeadFieldMat->rows();

    //##### Calc lead field combination #####

    std::cout << "Calculate lead field combinations. \n";

    m_iNumLeadFieldCombinations = nchoose2(m_iNumGridPoints+1);

    //######## CUDA START ########
        // allocate device vector
        m_dev_pVecPairIdxCombinations = new thrust::device_vector<int>(2 * m_iNumLeadFieldCombinations);
        // obtain raw pointer to device vector’s memory -> for usage in kernel
        m_dev_pPairIdxCombinations = thrust::raw_pointer_cast(&(*m_dev_pVecPairIdxCombinations)[0]);

        cuCalcPairCombinations<<<128,1>>>( m_iNumGridPoints, m_iNumLeadFieldCombinations, m_dev_pPairIdxCombinations);
    //######## CUDA END ########

    std::cout << "Lead Field combinations calculated. \n\n";

    //##### Calc lead field combination end #####

    std::cout << "Number of grid points: " << m_iNumGridPoints << "\n\n";

    std::cout << "Number of combinated points: " << m_iNumLeadFieldCombinations << "\n\n";

    std::cout << "Number of sources to find: " << m_iN << "\n\n";

    std::cout << "Threshold: " << m_dThreshold << "\n\n";

    //Init end

    std::cout << "##### Initialization CUDA RAP MUSIC completed ######\n\n\n";

    m_bIsInit = true;

    return m_bIsInit;
}


//*************************************************************************************************************

bool RapMusic_Cuda::calcRapMusic(HPCMatrix<float>* p_pMatMeasurement, RapDipoles<float>*& p_pRapDipoles)
{
    //if not initialized -> break
    if(!m_bIsInit)
    {
        std::cout << "RAP-Music wasn't initialized!"; //ToDo: catch this earlier
        return false;
    }

    //Test if data are correct
    if(p_pMatMeasurement->rows() != m_iNumChannels)
    {
        std::cout << "Lead Field channels do not fit to number of measurement channels!"; //ToDo: catch this earlier
        return false;
    }

//     //Inits
//     //Stop the time for benchmark purpose
//     clock_t start, end;
//     start = clock();


    //Calculate the signal subspace (t_dev_pMatPhi_s)
    cuHPCMatrix<float>* t_dev_pMatPhi_s = NULL;//(m_iNumChannels, t_r < m_iN ? m_iN : t_r);
    //separate kernel for calcPhi_s -> not possible because measurement is often too big for shared memory
    int t_r = calcPhi_s(*p_pMatMeasurement, t_dev_pMatPhi_s);


    int t_iMaxSearch = m_iN < t_r ? m_iN : t_r; //The smallest of Rank and Iterations

    if (t_r < m_iN)
    {
        std::cout << "Warning: Rank " << t_r << " of the measurement data is smaller than the " << m_iN;
        std::cout << " sources to find." << std::endl;
        std::cout << "         Searching now for " << t_iMaxSearch << " correlated sources.";
        std::cout << std::endl << std::endl;
    }

    //Create Orthogonal Projector
    //OrthProj
    HPCMatrix<float> t_matOrthProj(m_iNumChannels,m_iNumChannels);
    t_matOrthProj.setIdentity();

    cuHPCMatrix<float>* t_dev_pMatOrthProj = new cuHPCMatrix<float>(t_matOrthProj);//### CUDA ###

    //A_k_1
    HPCMatrix<float> t_matA_k_1(m_iNumChannels,t_iMaxSearch);
    t_matA_k_1.reset(0.0);//setZero();

    if (m_pMatGrid != NULL)
    {
        if(p_pRapDipoles != NULL)
            p_pRapDipoles->initRapDipoles(m_pMatGrid);
        else
            p_pRapDipoles = new RapDipoles<float>(m_pMatGrid);
    }
    else
    {
        if(p_pRapDipoles != NULL)
            delete p_pRapDipoles;

        p_pRapDipoles = new RapDipoles<float>();
    }

    std::cout << "##### Calculation of CUDA RAP MUSIC started ######\n\n";


    cuHPCMatrix<float>* t_dev_pMatProj_Phi_s = new cuHPCMatrix<float>(t_matOrthProj.rows(), t_dev_pMatPhi_s->cols());//### CUDA ###



    //new Version: Calculate projection before
    HPCMatrix<float> t_matProj_LeadField(m_dev_pLeadFieldMat->rows(), m_dev_pLeadFieldMat->cols());

    cuHPCMatrix<float>* t_dev_pMatProj_LeadField = new cuHPCMatrix<float>(m_dev_pLeadFieldMat->rows(), m_dev_pLeadFieldMat->cols());//### CUDA ###


    for(int r = 0; r < t_iMaxSearch; ++r)
    {

        //ToDO needs to be checked whether using device pointer is performant
        //t_dev_pMatProj_Phi_s = t_dev_pMatOrthProj*t_dev_pMatPhi_s;
        t_dev_pMatProj_Phi_s->cuHPCMatMult('N', 'N',*t_dev_pMatOrthProj,*t_dev_pMatPhi_s);//### CUDA ###


        //new Version: Calculating Projection before -> ToDo remove this later on
        t_matProj_LeadField = t_matOrthProj * (*m_pMatLeadField);//Subtract the found sources from the current found source

        //t_dev_pMatProj_LeadField = t_dev_pMatOrthProj*m_dev_pLeadFieldMat;
        t_dev_pMatProj_LeadField->cuHPCMatMult('N', 'N',*t_dev_pMatOrthProj,*m_dev_pLeadFieldMat);//### CUDA ###


        //###First Option###
        //Step 1: lt. Mosher 1998 -> Maybe tmp_Proj_Phi_S is already orthogonal -> so no SVD needed -> U_B = tmp_Proj_Phi_S;

            cuHPCMatrix<float>* t_dev_pMatU_B = new cuHPCMatrix<float>(t_dev_pMatPhi_s->rows(), t_dev_pMatPhi_s->cols());//### CUDA ###

            cuHPCValue<int> t_dev_iRank(0);//### CUDA ###


            int t_iTh_y = 8;//16; //ToDo: More than 8 threads - wrong results
            int t_iTh_z = 2;//1;

            int t_iMatSize_U_B = t_dev_pMatPhi_s->rows() * t_dev_pMatPhi_s->cols();
            int t_iWMatSize_U_B = t_dev_pMatPhi_s->cols();
            int t_iCacheYZSize_U_B = t_iTh_y*t_iTh_z;
            int t_iSVDCache_U_B = t_dev_pMatPhi_s->cols()+1+1;//rv1[m_iPairCols]; scale; s

            size_t t_iSharedMem_U_B = sizeof(float) * (t_iMatSize_U_B + t_iWMatSize_U_B + t_iCacheYZSize_U_B + t_iSVDCache_U_B);

            dim3 blocks = dim3( 1, 1);
            dim3 threads = dim3( 1, t_iTh_y, t_iTh_z);



            cuCalcU_B<<< blocks, threads, t_iSharedMem_U_B >>>
                                 ( t_dev_pMatProj_Phi_s->data(),
                                   t_dev_pMatProj_Phi_s->rows(),
                                   t_dev_pMatProj_Phi_s->cols(),
                                   t_dev_pMatU_B->data(),
                                   t_dev_iRank.data());
            HANDLE_ERROR( cudaThreadSynchronize() ); //to ensure that the kernel has completed

            int t_iFullRank_U_B = t_dev_iRank.toHostValue();



            HPCMatrix<float> t_matU_B(t_dev_pMatProj_Phi_s->rows(), t_iFullRank_U_B);
            // copy the array back from the GPU to the CPU
            HANDLE_ERROR( cudaMemcpy( t_matU_B.data(), t_dev_pMatU_B->data(),
                              t_iFullRank_U_B * t_dev_pMatProj_Phi_s->rows() * sizeof(float),
                              cudaMemcpyDeviceToHost ) );

            //ToDo - better to resize - drop no longer needed columns
            delete t_dev_pMatU_B;
            t_dev_pMatU_B = new cuHPCMatrix<float>(t_matU_B);//### CUDA ###



        //######## CUDA START ########
            // allocate device vector
            thrust::device_vector<float> t_dev_vecRoh(m_iNumLeadFieldCombinations);
            // obtain raw pointer to device vector’s memory -> for usage in kernel
            float * t_dev_pRoh = thrust::raw_pointer_cast(&t_dev_vecRoh[0]);
        //######## CUDA END ########

// subcorr GPU

        //######## CUDA START ########
            cudaEvent_t start, stop;
            float   elapsedTime;

            HANDLE_ERROR( cudaEventCreate( &start ) );
            HANDLE_ERROR( cudaEventCreate( &stop ) );


            t_iTh_y = 8;//16; //ToDo: More than 8 threads - wrong results
            t_iTh_z = 2;//1;

            int t_iPairMatSize = m_dev_pLeadFieldMat->rows() * m_iPairCols;
            int t_iWMatSize = m_iPairCols;
            int t_iCorMatSize = m_iPairCols*t_iFullRank_U_B;
            int t_iCacheYZSize = t_iTh_y*t_iTh_z;
            int t_iSVDCache = m_iPairCols+1+1;//rv1[m_iPairCols]; scale; s

            size_t t_iSharedMemPerPairMat = sizeof(float) * (t_iPairMatSize + t_iWMatSize + t_iCorMatSize + t_iCacheYZSize + t_iSVDCache);
            int t_iPairMatsPerMultiProcessor = m_iSharedMemoryPerMultiProcessor/t_iSharedMemPerPairMat;
            std::cout << "Shared Memory Usage: " << t_iSharedMemPerPairMat << " Byte x " << t_iPairMatsPerMultiProcessor << std::endl;

            int t_iPairMatsPerBlock = ceil((float)(t_iPairMatsPerMultiProcessor)/(float)m_iMaxBlocksPerMultiProcessor);//=threadDim.x
/*DIRTY HACK*/  t_iPairMatsPerBlock = 2;//t_iPairMatsPerBlock > 2 ? 2 : t_iPairMatsPerBlock;//ToDo Debug when 3 Mats per Block we get the wrong result
            std::cout << "Pair Mats per Block: " << t_iPairMatsPerBlock << std::endl;

            size_t t_iSharedMemPerBlock = t_iSharedMemPerPairMat * t_iPairMatsPerBlock;

            blocks = dim3( /*7381*/ 64*m_iMultiProcessorCount, 1);
            threads = dim3( t_iPairMatsPerBlock, t_iTh_y, t_iTh_z);


            HANDLE_ERROR( cudaEventRecord( start, 0 ) );

            RapMusicSubcorr<<<blocks, threads, t_iSharedMemPerBlock>>>
                                              ( t_dev_pMatProj_LeadField->data(),
                                                t_dev_pMatProj_LeadField->rows(),
                                                t_dev_pMatProj_LeadField->cols(),
                                                m_dev_pPairIdxCombinations,
                                                m_iNumLeadFieldCombinations,

                                                t_dev_pMatU_B->data(),
                                                t_iFullRank_U_B,
                                                t_dev_pRoh );
            HANDLE_ERROR( cudaThreadSynchronize() ); //to ensure that the kernel has completed

            HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
            HANDLE_ERROR( cudaEventSynchronize( stop ) );
            HANDLE_ERROR( cudaEventElapsedTime( &elapsedTime,
                                                start, stop ) );

            // free events
            HANDLE_ERROR( cudaEventDestroy( start ) );
            HANDLE_ERROR( cudaEventDestroy( stop ) );

            std::cout << "Time Elapsed: " << elapsedTime << " ms" << std::endl;
        //######## CUDA END ########

        //Find the maximum of correlation 
        //######## CUDA THRUST START ########
            //max_element returns an iterator, so to convert that into a position we subtract the iterator at the beginning of the vector.
            int t_iMaxIdx = thrust::max_element(t_dev_vecRoh.begin(), t_dev_vecRoh.end()) - t_dev_vecRoh.begin(); 
            float t_val_roh_k = t_dev_vecRoh[t_iMaxIdx];
        //######## THRUST CUDA END ########

        //get positions in sparsed leadfield from index combinations;
        int t_iIdx1 = (*m_dev_pVecPairIdxCombinations)[2*t_iMaxIdx];
        int t_iIdx2 = (*m_dev_pVecPairIdxCombinations)[2*t_iMaxIdx+1];

        // (Idx+1) because of MATLAB positions -> starting with 1 not with 0
        std::cout << "Iteration: " << r+1 << " of " << t_iMaxSearch
            << "; Correlation: " << t_val_roh_k<< "; Position (Idx+1): " << t_iIdx1+1 << " - " << t_iIdx2+1 <<"\n\n";

        //Calculations with the max correlated dipole pair G_k_1
        HPCMatrix<float> t_matG_k_1(t_matProj_LeadField.rows(),6);
        getLeadFieldPair(*m_pMatLeadField, t_matG_k_1, t_iIdx1, t_iIdx2);

        HPCMatrix<float> t_matProj_G_k_1(t_matOrthProj.rows(), t_matG_k_1.cols());
        t_matProj_G_k_1 = t_matOrthProj * t_matG_k_1;//Subtract the found sources from the current found source

        //Calculate source direction
        //source direction (p_pMatPhi) for current source r (phi_k_1)
        HPCMatrix<float> t_vec_phi_k_1(6, 1);
        subcorr(t_matProj_G_k_1, t_matU_B, t_vec_phi_k_1);//Correlate the current source to calculate the direction

        //Set return values
        p_pRapDipoles->insertSource(t_iIdx1, t_iIdx2, t_vec_phi_k_1.data(), t_val_roh_k);
        
        //Stop Searching when Correlation is smaller then the Threshold
        if (t_val_roh_k < m_dThreshold)
        {
            std::cout << "Searching stopped, last correlation " << t_val_roh_k;
            std::cout << " is smaller then the given threshold " << m_dThreshold << std::endl << std::endl;
            break;
        }
        
        //Calculate A_k_1 = [a_theta_1..a_theta_k_1] matrix for subtraction of found source
        calcA_k_1(t_matG_k_1, t_vec_phi_k_1, r, t_matA_k_1);

        //Calculate new orthogonal Projector (Pi_k_1)
        calcOrthProj(t_matA_k_1, t_matOrthProj);


        //#### CUDA START ####
            HANDLE_ERROR( cudaMemcpy(   t_dev_pMatOrthProj->data(),
                                        t_matOrthProj.data(),
                                        sizeof(float) * t_matOrthProj.size(),
                                        cudaMemcpyHostToDevice ) );
        //#### CUDA END ####


        //garbage collecting
            // free the memory allocated on the GPU
            delete t_dev_pMatU_B;

            // free the memory we allocated on the CPU

    }

    //garbage collecting
        // free the memory allocated on the GPU
        delete t_dev_pMatProj_LeadField;

        delete t_dev_pMatProj_Phi_s;

        delete t_dev_pMatOrthProj;

        delete t_dev_pMatPhi_s;

        // free the memory we allocated on the CPU

    std::cout << "##### Calculation of CUDA RAP MUSIC completed ######\n\n";

//     end = clock();
// 
//     float t_fElapsedTime = ( (float)(end-start) / (float)CLOCKS_PER_SEC ) * 1000.0f;
//     std::cout << "Time Elapsed: " << t_fElapsedTime << " ms" << std::endl << std::endl;


    //garbage collecting
    //ToDo


    return true;
}


//*************************************************************************************************************

bool RapMusic_Cuda::calcPowellRAPMusic(HPCMatrix<float>* p_pMatMeasurement, RapDipoles<float>*& p_pRapDipoles)
{
    //if not initialized -> break
    if(!m_bIsInit)
    {
        std::cout << "RAP-Music wasn't initialized!"; //ToDo: catch this earlier
        return false;
    }

    //Test if data are correct
    if(p_pMatMeasurement->rows() != m_iNumChannels)
    {
        std::cout << "Lead Field channels do not fit to number of measurement channels!"; //ToDo: catch this earlier
        return false;
    }

//     //Inits
//     //Stop the time for benchmark purpose
//     clock_t start, end;
//     start = clock();


    //Calculate the signal subspace (t_dev_pMatPhi_s)
    cuHPCMatrix<float>* t_dev_pMatPhi_s = NULL;//(m_iNumChannels, t_r < m_iN ? m_iN : t_r);
    //separate kernel for calcPhi_s -> not possible because measurement is often too big for shared memory
    int t_r = calcPhi_s(*p_pMatMeasurement, t_dev_pMatPhi_s);


    int t_iMaxSearch = m_iN < t_r ? m_iN : t_r; //The smallest of Rank and Iterations

    if (t_r < m_iN)
    {
        std::cout << "Warning: Rank " << t_r << " of the measurement data is smaller than the " << m_iN;
        std::cout << " sources to find." << std::endl;
        std::cout << "         Searching now for " << t_iMaxSearch << " correlated sources.";
        std::cout << std::endl << std::endl;
    }

    //Create Orthogonal Projector
    //OrthProj
    HPCMatrix<float> t_matOrthProj(m_iNumChannels,m_iNumChannels);
    t_matOrthProj.setIdentity();

    cuHPCMatrix<float>* t_dev_pMatOrthProj = new cuHPCMatrix<float>(t_matOrthProj);//### CUDA ###

    //A_k_1
    HPCMatrix<float> t_matA_k_1(m_iNumChannels,t_iMaxSearch);
    t_matA_k_1.reset(0.0);//setZero();

    if (m_pMatGrid != NULL)
    {
        if(p_pRapDipoles != NULL)
            p_pRapDipoles->initRapDipoles(m_pMatGrid);
        else
            p_pRapDipoles = new RapDipoles<float>(m_pMatGrid);
    }
    else
    {
        if(p_pRapDipoles != NULL)
            delete p_pRapDipoles;

        p_pRapDipoles = new RapDipoles<float>();
    }

    std::cout << "##### Calculation of CUDA RAP MUSIC started ######\n\n";


    cuHPCMatrix<float>* t_dev_pMatProj_Phi_s = new cuHPCMatrix<float>(t_matOrthProj.rows(), t_dev_pMatPhi_s->cols());//### CUDA ###



    //new Version: Calculate projection before
    HPCMatrix<float> t_matProj_LeadField(m_dev_pLeadFieldMat->rows(), m_dev_pLeadFieldMat->cols());

    cuHPCMatrix<float>* t_dev_pMatProj_LeadField = new cuHPCMatrix<float>(m_dev_pLeadFieldMat->rows(), m_dev_pLeadFieldMat->cols());//### CUDA ###


    for(int r = 0; r < t_iMaxSearch; ++r)
    {

        //ToDO needs to be checked whether using device pointer is performant
        //t_dev_pMatProj_Phi_s = t_dev_pMatOrthProj*t_dev_pMatPhi_s;
        t_dev_pMatProj_Phi_s->cuHPCMatMult('N', 'N',*t_dev_pMatOrthProj,*t_dev_pMatPhi_s);//### CUDA ###


        //new Version: Calculating Projection before -> ToDo remove this later on
        t_matProj_LeadField = t_matOrthProj * (*m_pMatLeadField);//Subtract the found sources from the current found source

        //t_dev_pMatProj_LeadField = t_dev_pMatOrthProj*m_dev_pLeadFieldMat;
        t_dev_pMatProj_LeadField->cuHPCMatMult('N', 'N',*t_dev_pMatOrthProj,*m_dev_pLeadFieldMat);//### CUDA ###


        //###First Option###
        //Step 1: lt. Mosher 1998 -> Maybe tmp_Proj_Phi_S is already orthogonal -> so no SVD needed -> U_B = tmp_Proj_Phi_S;

            cuHPCMatrix<float>* t_dev_pMatU_B = new cuHPCMatrix<float>(t_dev_pMatPhi_s->rows(), t_dev_pMatPhi_s->cols());//### CUDA ###

            cuHPCValue<int> t_dev_iRank(0);//### CUDA ###


            int t_iTh_y = 8;//16; //ToDo: More than 8 threads - wrong results
            int t_iTh_z = 2;//1;

            int t_iMatSize_U_B = t_dev_pMatPhi_s->rows() * t_dev_pMatPhi_s->cols();
            int t_iWMatSize_U_B = t_dev_pMatPhi_s->cols();
            int t_iCacheYZSize_U_B = t_iTh_y*t_iTh_z;
            int t_iSVDCache_U_B = t_dev_pMatPhi_s->cols()+1+1;//rv1[m_iPairCols]; scale; s

            size_t t_iSharedMem_U_B = sizeof(float) * (t_iMatSize_U_B + t_iWMatSize_U_B + t_iCacheYZSize_U_B + t_iSVDCache_U_B);

            dim3 blocks = dim3( 1, 1);
            dim3 threads = dim3( 1, t_iTh_y, t_iTh_z);



            cuCalcU_B<<< blocks, threads, t_iSharedMem_U_B >>>
                                 ( t_dev_pMatProj_Phi_s->data(),
                                   t_dev_pMatProj_Phi_s->rows(),
                                   t_dev_pMatProj_Phi_s->cols(),
                                   t_dev_pMatU_B->data(),
                                   t_dev_iRank.data());
            HANDLE_ERROR( cudaThreadSynchronize() ); //to ensure that the kernel has completed

            int t_iFullRank_U_B = t_dev_iRank.toHostValue();



            HPCMatrix<float> t_matU_B(t_dev_pMatProj_Phi_s->rows(), t_iFullRank_U_B);
            // copy the array back from the GPU to the CPU
            HANDLE_ERROR( cudaMemcpy( t_matU_B.data(), t_dev_pMatU_B->data(),
                              t_iFullRank_U_B * t_dev_pMatProj_Phi_s->rows() * sizeof(float),
                              cudaMemcpyDeviceToHost ) );

            //ToDo - better to resize - drop no longer needed columns
            delete t_dev_pMatU_B;
            t_dev_pMatU_B = new cuHPCMatrix<float>(t_matU_B);//### CUDA ###



        //######## CUDA START ########
            // allocate device vector
            thrust::device_vector<float> t_dev_vecRoh(m_iNumLeadFieldCombinations);
            // obtain raw pointer to device vector’s memory -> for usage in kernel
            float * t_dev_pRoh = thrust::raw_pointer_cast(&t_dev_vecRoh[0]);

            // allocate device vector
            thrust::device_vector<int> t_dev_vecRowIndezes(m_iNumGridPoints);
            // obtain raw pointer to device vector’s memory -> for usage in kernel
            int * t_dev_pRowIndezes = thrust::raw_pointer_cast(&t_dev_vecRowIndezes[0]);

        //######## CUDA END ########

// subcorr GPU

        //Powell
        int t_iCurrentRow = 2;

        int t_iIdx1 = -1;
        int t_iIdx2 = -1;

        int t_iMaxIdx_old = -1;
        int t_iMaxIdx = -1;

        int t_iMaxFound = 0;

        float t_val_roh_k = 0;

        int t_iNumVecElements = m_iNumGridPoints;

        while(t_iMaxFound == 0)
        {


        //######## CUDA START ########
            cudaEvent_t start, stop;
            float   elapsedTime;

            HANDLE_ERROR( cudaEventCreate( &start ) );
            HANDLE_ERROR( cudaEventCreate( &stop ) );

            //Powell Indizes
            cuPowellIdxVec<<<32, 32>>>( t_iCurrentRow,
                                        t_iNumVecElements,
                                        t_dev_pRowIndezes );
            HANDLE_ERROR( cudaThreadSynchronize() ); //to ensure that the kernel has completed

//             //DEBUG
//             thrust::host_vector<int> h_vec(m_iNumGridPoints);
//             // transfer data back to host
//             thrust::copy(t_dev_vecRowIndezes.begin(), t_dev_vecRowIndezes.end(), h_vec.begin());
//             std::cout << "indezes" << std::endl;
//              for(int i = 0; i < 10; ++i)
//                  std::cout << h_vec[i] << std::endl;
//              //DEBUG

            t_iTh_y = 8;//16; //ToDo: More than 8 threads - wrong results
            t_iTh_z = 2;//1;

            int t_iPairMatSize = m_dev_pLeadFieldMat->rows() * m_iPairCols;
            int t_iWMatSize = m_iPairCols;
            int t_iCorMatSize = m_iPairCols*t_iFullRank_U_B;
            int t_iCacheYZSize = t_iTh_y*t_iTh_z;
            int t_iSVDCache = m_iPairCols+1+1;//rv1[m_iPairCols]; scale; s

            size_t t_iSharedMemPerPairMat = sizeof(float) * (t_iPairMatSize + t_iWMatSize + t_iCorMatSize + t_iCacheYZSize + t_iSVDCache);
            int t_iPairMatsPerMultiProcessor = m_iSharedMemoryPerMultiProcessor/t_iSharedMemPerPairMat;
            std::cout << "Shared Memory Usage: " << t_iSharedMemPerPairMat << " Byte x " << t_iPairMatsPerMultiProcessor << std::endl;

            int t_iPairMatsPerBlock = ceil((float)(t_iPairMatsPerMultiProcessor)/(float)m_iMaxBlocksPerMultiProcessor);//=threadDim.x
/*DIRTY HACK*/  t_iPairMatsPerBlock = 2;//t_iPairMatsPerBlock > 2 ? 2 : t_iPairMatsPerBlock;//ToDo Debug when 3 Mats per Block we get the wrong result
            std::cout << "Pair Mats per Block: " << t_iPairMatsPerBlock << std::endl;

            size_t t_iSharedMemPerBlock = t_iSharedMemPerPairMat * t_iPairMatsPerBlock;

            blocks = dim3( /*7381*/ 64*m_iMultiProcessorCount, 1);
            threads = dim3( t_iPairMatsPerBlock, t_iTh_y, t_iTh_z);


            HANDLE_ERROR( cudaEventRecord( start, 0 ) );

            PowellRapMusicSubcorr<<<blocks, threads, t_iSharedMemPerBlock>>>
                                              ( t_dev_pMatProj_LeadField->data(),
                                                t_dev_pMatProj_LeadField->rows(),
                                                t_dev_pMatProj_LeadField->cols(),
                                                m_dev_pPairIdxCombinations,
                                                t_dev_pRowIndezes,
                                                t_iNumVecElements,

                                                t_dev_pMatU_B->data(),
                                                t_iFullRank_U_B,
                                                t_dev_pRoh );
            HANDLE_ERROR( cudaThreadSynchronize() ); //to ensure that the kernel has completed

            HANDLE_ERROR( cudaEventRecord( stop, 0 ) );
            HANDLE_ERROR( cudaEventSynchronize( stop ) );
            HANDLE_ERROR( cudaEventElapsedTime( &elapsedTime,
                                                start, stop ) );

            // free events
            HANDLE_ERROR( cudaEventDestroy( start ) );
            HANDLE_ERROR( cudaEventDestroy( stop ) );

            std::cout << "Time Elapsed: " << elapsedTime << " ms" << std::endl;
        //######## CUDA END ########



        //Find the maximum of correlation 
        //######## CUDA THRUST START ########
            //max_element returns an iterator, so to convert that into a position we subtract the iterator at the beginning of the vector.
            t_iMaxIdx = thrust::max_element(t_dev_vecRoh.begin(), t_dev_vecRoh.end()) - t_dev_vecRoh.begin(); 
            t_val_roh_k = t_dev_vecRoh[t_iMaxIdx];
        //######## THRUST CUDA END ########

            //Powell
            if(t_iMaxIdx == t_iMaxIdx_old)
            {
                t_iMaxFound = 1;
                break;
            }
            else
            {
                t_iMaxIdx_old = t_iMaxIdx;
                //get positions in sparsed leadfield from index combinations;
                t_iIdx1 = (*m_dev_pVecPairIdxCombinations)[2*t_iMaxIdx];
                t_iIdx2 = (*m_dev_pVecPairIdxCombinations)[2*t_iMaxIdx+1];
            }

            //set new index
            if(t_iIdx1 == t_iCurrentRow)
                t_iCurrentRow = t_iIdx2;
            else
                t_iCurrentRow = t_iIdx1;

        }

        // (Idx+1) because of MATLAB positions -> starting with 1 not with 0
        std::cout << "Iteration: " << r+1 << " of " << t_iMaxSearch
            << "; Correlation: " << t_val_roh_k<< "; Position (Idx+1): " << t_iIdx1+1 << " - " << t_iIdx2+1 <<"\n\n";

        //Calculations with the max correlated dipole pair G_k_1
        HPCMatrix<float> t_matG_k_1(t_matProj_LeadField.rows(),6);
        getLeadFieldPair(*m_pMatLeadField, t_matG_k_1, t_iIdx1, t_iIdx2);

        HPCMatrix<float> t_matProj_G_k_1(t_matOrthProj.rows(), t_matG_k_1.cols());
        t_matProj_G_k_1 = t_matOrthProj * t_matG_k_1;//Subtract the found sources from the current found source

        //Calculate source direction
        //source direction (p_pMatPhi) for current source r (phi_k_1)
        HPCMatrix<float> t_vec_phi_k_1(6, 1);
        subcorr(t_matProj_G_k_1, t_matU_B, t_vec_phi_k_1);//Correlate the current source to calculate the direction

        //Set return values
        p_pRapDipoles->insertSource(t_iIdx1, t_iIdx2, t_vec_phi_k_1.data(), t_val_roh_k);
        
        //Stop Searching when Correlation is smaller then the Threshold
        if (t_val_roh_k < m_dThreshold)
        {
            std::cout << "Searching stopped, last correlation " << t_val_roh_k;
            std::cout << " is smaller then the given threshold " << m_dThreshold << std::endl << std::endl;
            break;
        }
        
        //Calculate A_k_1 = [a_theta_1..a_theta_k_1] matrix for subtraction of found source
        calcA_k_1(t_matG_k_1, t_vec_phi_k_1, r, t_matA_k_1);

        //Calculate new orthogonal Projector (Pi_k_1)
        calcOrthProj(t_matA_k_1, t_matOrthProj);


        //#### CUDA START ####
            HANDLE_ERROR( cudaMemcpy(   t_dev_pMatOrthProj->data(),
                                        t_matOrthProj.data(),
                                        sizeof(float) * t_matOrthProj.size(),
                                        cudaMemcpyHostToDevice ) );
        //#### CUDA END ####


        //garbage collecting
            // free the memory allocated on the GPU
            delete t_dev_pMatU_B;

            // free the memory we allocated on the CPU

    }

    //garbage collecting
        // free the memory allocated on the GPU
        delete t_dev_pMatProj_LeadField;

        delete t_dev_pMatProj_Phi_s;

        delete t_dev_pMatOrthProj;

        delete t_dev_pMatPhi_s;

        // free the memory we allocated on the CPU

    std::cout << "##### Calculation of CUDA RAP MUSIC completed ######\n\n";

//     end = clock();
// 
//     float t_fElapsedTime = ( (float)(end-start) / (float)CLOCKS_PER_SEC ) * 1000.0f;
//     std::cout << "Time Elapsed: " << t_fElapsedTime << " ms" << std::endl << std::endl;


    //garbage collecting
    //ToDo


    return true;
}


//*************************************************************************************************************

int RapMusic_Cuda::nchoose2(int n)
{
    //nchoosek(n, k) with k = 2, equals n*(n-1)*0.5

    int t_iNumOfCombination = (int)(n*(n-1)*0.5);

    return t_iNumOfCombination;
}


//*************************************************************************************************************

//template <class T>
int  RapMusic_Cuda/*<T>*/::calcPhi_s(const HPCMatrix<float>& p_pMatMeasurement, cuHPCMatrix<float>* &p_dev_pMatPhi_s)
{
    //Calculate p_dev_pMatPhi_s
    HPCMatrix<float> t_matF;
    if (p_pMatMeasurement.cols() > p_pMatMeasurement.rows())
    {
        t_matF = makeSquareMat(p_pMatMeasurement); //FF^T
    }
    else
    {
        t_matF = p_pMatMeasurement;
    }

    SVD phi_sSVD(t_matF, 1);

    int t_r = getRank(phi_sSVD.singularValues());

    int t_iCols = t_r; //t_r < m_iN ? m_iN : t_r;

    if (p_dev_pMatPhi_s != NULL)
        delete p_dev_pMatPhi_s;

    //m_iNumChannels has to be equal to t_svdF.matrixU().rows()
    p_dev_pMatPhi_s = new cuHPCMatrix<float>(m_iNumChannels, t_iCols);

    //assign the signal subspace
    // copy the array from the CPU to the GPU
    HANDLE_ERROR(   cudaMemcpy( p_dev_pMatPhi_s->data(), phi_sSVD.matrixU()->data(),
                                sizeof(float) * m_iNumChannels *t_iCols,
                                cudaMemcpyHostToDevice ) );

    //ToDO Use jojos svd instead of cula

    //garbage collecting

    return t_r;
}


//*************************************************************************************************************
//Direction Subcorr
float RapMusic_Cuda::subcorr(HPCMatrix<float>& p_matProj_G, HPCMatrix<float>& p_matU_B, HPCMatrix<float>& p_vec_phi_k_1)
{
    //Orthogonalisierungstest wegen performance weggelassen -> ohne is es viel schneller
 
    SVD t_svdProj_G(p_matProj_G, 3);

    HPCMatrix<float> U_A_T(6, t_svdProj_G.matrixU()->rows());

    U_A_T = t_svdProj_G.matrixU()->transpose();

    HPCMatrix<float>* sigma_A = t_svdProj_G.singularValues();

    HPCMatrix<float>* V_A = t_svdProj_G.matrixV();

    //lt. Mosher 1998 ToDo: Only Retain those Components of U_A and U_B that correspond to nonzero singular values
    //for U_A and U_B the number of columns corresponds to their ranks
    //-> reduce to rank only when directions aren't calculated, otherwise use the full U_A_T

    HPCMatrix<float> Cor(6, p_matU_B.cols());

    //Step 2: compute the subspace correlation
    Cor = U_A_T*p_matU_B;//lt. Mosher 1998: C = U_A^T * U_B


    HPCMatrix<float>* t_vecSigma_C;

    //Step 4
    HPCMatrix<float>* U_C;

    if (Cor.cols() > Cor.rows())
    {
        Cor = Cor.transpose();//adjoint(); //for complex it has to be adjunct
        
        SVD svdOfCor_H(Cor, 2);

        U_C = new HPCMatrix<float>(svdOfCor_H.matrixV()->rows(), svdOfCor_H.matrixV()->cols());
        //because Cor Hermitesch U and V are exchanged
        memcpy(U_C->data(),svdOfCor_H.matrixV()->data(),(U_C->size()*sizeof(float)));

        t_vecSigma_C = new HPCMatrix<float>(svdOfCor_H.singularValues()->rows(), svdOfCor_H.singularValues()->cols());
        memcpy(t_vecSigma_C->data(),svdOfCor_H.singularValues()->data(),(t_vecSigma_C->size()*sizeof(float)));
    }
    else
    {
        SVD svdOfCor(Cor, 1);

        U_C = new HPCMatrix<float>(svdOfCor.matrixU()->rows(), svdOfCor.matrixU()->cols());
        memcpy(U_C->data(),svdOfCor.matrixU()->data(),(U_C->size()*sizeof(float)));

        t_vecSigma_C = new HPCMatrix<float>(svdOfCor.singularValues()->rows(), svdOfCor.singularValues()->cols());
        memcpy(t_vecSigma_C->data(),svdOfCor.singularValues()->data(),(t_vecSigma_C->size()*sizeof(float)));
    }

    //invert sigma A
    HPCMatrix<float> sigma_a_inv(sigma_A->rows(), sigma_A->rows());
    for (int i = 0; i < sigma_A->rows(); ++i)
    {
        sigma_a_inv(i,i) = 1/sigma_A->data()[i];
    }

    HPCMatrix<float> X(6,U_C->cols());
    X = ((*V_A)*sigma_a_inv)*(*U_C);//X = V_A*Sigma_A^-1*U_C

    float norm_X = 0;
    for(int i = 0; i < 6; ++i)
        norm_X += pow(X.data()[i], 2);

    norm_X = 1/sqrt(norm_X);

    //Multiply a scalar with an Array -> linear transform
    for(int i = 0; i < 6; ++i)
        p_vec_phi_k_1.data()[i] = X.data()[i]*norm_X;//u1 = x1/||x1|| this is the orientation

    //Step 3
    float ret_sigma_C;
    ret_sigma_C = t_vecSigma_C->data()[0]; //Take only the correlation of the first principal components

    //garbage collecting
    delete U_C;
    delete t_vecSigma_C;

    return ret_sigma_C;
}


//*************************************************************************************************************

void RapMusic_Cuda::calcA_k_1(  const HPCMatrix<float>& p_matG_k_1,
                                const HPCMatrix<float>& p_matPhi_k_1,
                                const int p_iIdxk_1,
                                HPCMatrix<float>& p_matA_k_1)
{
    //Calculate A_k_1 = [a_theta_1..a_theta_k_1] matrix for subtraction of found source
    HPCMatrix<float> t_vec_a_theta_k_1(p_matG_k_1.rows(),1);

    t_vec_a_theta_k_1 = p_matG_k_1*p_matPhi_k_1; // a_theta_k_1 = G_k_1*phi_k_1   this corresponds to the normalized signal component in subspace r

    memcpy( p_matA_k_1.data()+p_iIdxk_1*p_matA_k_1.rows(),
            t_vec_a_theta_k_1.data(),
            (p_matA_k_1.rows()*sizeof(float)));
}


//*************************************************************************************************************

void RapMusic_Cuda::calcOrthProj(const HPCMatrix<float>& p_matA_k_1, HPCMatrix<float>& p_matOrthProj)
{
    //Calculate OrthProj=I-A_k_1*(A_k_1'*A_k_1)^-1*A_k_1' //Wetterling -> A_k_1 = Gain

    HPCMatrix<float> t_matA_k_1_tmp(p_matA_k_1.cols(), p_matA_k_1.cols());
    t_matA_k_1_tmp = p_matA_k_1.transpose()/*adjoint()*/*p_matA_k_1;//A_k_1'*A_k_1 = A_k_1_tmp -> A_k_1' has to be adjoint for complex


    int t_size = t_matA_k_1_tmp.cols();

    while (!t_matA_k_1_tmp(t_size-1,t_size-1))
    {
        --t_size;
    }

    HPCMatrix<float> t_matA_k_1_tmp_inv(t_matA_k_1_tmp.rows(), t_matA_k_1_tmp.cols());

    HPCMatrix<float> t_matA_k_1_tmpsubmat = t_matA_k_1_tmp.get(0,0,t_size,t_size);
    LU t_matA_k_1_LU(&t_matA_k_1_tmpsubmat);
    for(int i = 0; i < t_matA_k_1_tmpsubmat.rows(); ++i)
        for(int j = 0; j < t_matA_k_1_tmpsubmat.cols(); ++j)
            t_matA_k_1_tmp_inv(i,j) = t_matA_k_1_LU.invert()(i,j);//(A_k_1_tmp)^-1 = A_k_1_tmp_inv


    t_matA_k_1_tmp.resize(p_matA_k_1.rows(), p_matA_k_1.cols());

    t_matA_k_1_tmp = p_matA_k_1*t_matA_k_1_tmp_inv;//(A_k_1*A_k_1_tmp_inv) = A_k_1_tmp


    HPCMatrix<float> t_matA_k_1_tmp2(p_matA_k_1.rows(), p_matA_k_1.rows());
    t_matA_k_1_tmp2 = t_matA_k_1_tmp*p_matA_k_1.transpose();//adjoint();//(A_k_1_tmp)*A_k_1' -> here A_k_1' is only transposed - it has to be adjoint

    HPCMatrix<float> I(m_iNumChannels,m_iNumChannels);
    I.diag(1.0);//setIdentity();

    p_matOrthProj = I-t_matA_k_1_tmp2; //OrthProj=I-A_k_1*(A_k_1'*A_k_1)^-1*A_k_1';

//     //garbage collecting
//     //ToDo
}


//*************************************************************************************************************
//ToDo don't make a real copy
void RapMusic_Cuda::getLeadFieldPair(   HPCMatrix<float>& p_matLeadField,
                                        HPCMatrix<float>& p_matLeadField_Pair,
                                        int p_iIdx1, int p_iIdx2)
{
    memcpy( p_matLeadField_Pair.data(),
            p_matLeadField.data()+p_iIdx1*3*p_matLeadField.rows(),
            (p_matLeadField.rows()*3*sizeof(float)));

    memcpy( p_matLeadField_Pair.data()+3*p_matLeadField.rows(),
            p_matLeadField.data()+p_iIdx2*3*p_matLeadField.rows(),
            (p_matLeadField.rows()*3*sizeof(float)));
}

}//Namespace