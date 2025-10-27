import logo from '@/assets/images/f5_logo.png'

// ==============================|| LOGO ||============================== //

const Logo = () => {
    return (
        <div style={{ alignItems: 'center', display: 'flex', flexDirection: 'row', marginLeft: '10px' }}>
            <img
                style={{ objectFit: 'contain', height: 'auto', width: 150 }}
                src={logo}
                alt='F5 Logo'
            />
        </div>
    )
}

export default Logo
