function [cand, prev] = bACS(m_0, m_1, m_2, m_3)
    if m_0 <= m_1
        min0 = m_0; p0 = 1;
    else
        min0 = m_1; p0 = 2;
    end
    if m_2 <= m_3
        min1 = m_2; p1 = 3;
    else
        min1 = m_3; p1 = 4;
    end

    if min0 <= min1
        cand = min0; prev = p0;
    else
        cand = min1; prev = p1;
    end
end
